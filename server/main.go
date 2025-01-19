package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/gorilla/mux"
)

type Item struct {
	ID    int `json:"id"`
	Score int `json:"score"`
}

var dynamoClient *dynamodb.Client

const tableName = "demo_table"

func main() {
	// Load AWS configuration
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-west-2"),
		// config.WithBaseEndpoint("http://localhost:4566"),
	)
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}

	dynamoClient = dynamodb.NewFromConfig(cfg, func(o *dynamodb.Options) {
		o.Region = "us-west-2"
		// o.BaseEndpoint = aws.String("http://localhost:4566")
	})

	// Setup HTTP Router
	router := mux.NewRouter()
	router.HandleFunc("/item", handlePost).Methods("POST")
	router.HandleFunc("/item/{id}", handleGet).Methods("GET")

	log.Println("Server running on port 8081")
	log.Fatal(http.ListenAndServe(":8081", router))
}

func handlePost(w http.ResponseWriter, r *http.Request) {
	var item Item
	err := json.NewDecoder(r.Body).Decode(&item)
	if err != nil || item.ID == 0 || item.Score == 0 {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}
	log.Printf("Received item: %+v\n", item)
	_, err = dynamoClient.PutItem(r.Context(), &dynamodb.PutItemInput{
		TableName: aws.String(tableName),
		Item: map[string]types.AttributeValue{
			"ID":    &types.AttributeValueMemberN{Value: strconv.Itoa(item.ID)},
			"Score": &types.AttributeValueMemberN{Value: strconv.Itoa(item.Score)},
		},
	})
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to write to DynamoDB: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprintln(w, "Item added successfully")
}

func handleGet(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	// Read from DynamoDB
	resp, err := dynamoClient.GetItem(r.Context(), &dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]types.AttributeValue{
			"ID": &types.AttributeValueMemberN{Value: id},
		},
	})
	if err != nil || resp.Item == nil {
		http.Error(w, "Item not found", http.StatusNotFound)
		return
	}

	// Convert DynamoDB item to JSON
	score, _ := strconv.Atoi(resp.Item["Score"].(*types.AttributeValueMemberN).Value)
	item := Item{
		ID:    idAsInt(id),
		Score: score,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(item)
}

func idAsInt(id string) int {
	value, err := strconv.Atoi(id)
	if err != nil {
		return 0
	}
	return value
}
