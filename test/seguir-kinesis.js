"use strict";

const AWS = require("aws-sdk");
const fs = require("fs");
const assert = require("assert");

const kinesis = new AWS.Kinesis({
  accessKeyId: "accessKeyId",
  secretAccessKey: "secretAccessKey",
  region: "us-east-1",
  endpoint: "http://localhost:4567",
  apiVersion: "2013-12-02",
  sslEnabled: false
});

const getShardIterator = (streamName, data) => {
  return kinesis.getShardIterator({
    StreamName: streamName,
    ShardId: data.StreamDescription.Shards[0].ShardId,
    ShardIteratorType: "LATEST"
  }).promise();
};

const getRecords = (data) => {
  return kinesis.getRecords({
    Limit: 10,
    ShardIterator: data.ShardIterator
  }).promise();
};

const readRecords = (data) => {
  if (data.Records.length === 0) {
    return getRecords({
      ShardIterator: data.NextShardIterator
    }).then(readRecords.bind(this));
  }

  return Promise.resolve(data);
}

describe("seguir-kinesis", function() {
  describe("Static partition key contracts", function() {
    it("should publish record with static partition key", function(done) {
      const record = "Test data.";
      fs.writeFileSync("/tmp/test.partition.key.log", record + "\n");
      kinesis.waitFor("streamExists", {
          StreamName: "test.partition.key"
        }).promise()
        .then(getShardIterator.bind(this, "test.partition.key"))
        .then(getRecords.bind(this))
        .then(readRecords.bind(this))
        .then((data) => {
          const records = data.Records;
          assert.equal(records.length, 1, "Expected a single message to be published.");
          assert.equal(Buffer.from(records[0].Data, "base64").toString("utf8"), record, "Received record data was not the same.");
          assert.equal(records[0].PartitionKey, "TestPartitionKey", "PartitionKey was not expected.");
          done();
        })
        .catch((err) => {
          throw err;
        });
    });
  });

  describe("Dynamic partition key contracts", function() {
    it("should publish record with dynamic partition key", function(done) {
      const record = JSON.stringify({
        "X-TraceId": "Test123",
        "message": "Test data."
      });

      fs.writeFileSync("/tmp/test.partition.key.property.log", record + "\n");
      kinesis.waitFor("streamExists", {
          StreamName: "test.partition.key.property"
        }).promise()
        .then(getShardIterator.bind(this, "test.partition.key.property"))
        .then(getRecords.bind(this))
        .then(readRecords.bind(this))
        .then((data) => {
          const records = data.Records;
          assert.equal(records.length, 1, "Expected a single message to be published.");
          assert.equal(Buffer.from(records[0].Data, "base64").toString("utf8"), record, "Received record data was not the same.");
          assert.equal(records[0].PartitionKey, "Test123", "PartitionKey was not expected.");
          done();
        })
        .catch((err) => {
          console.error(err);
        });
    });
  });

  describe("Date based partition key contracts", function() {
    it("should publish record with date based partition key", function(done) {
      const record = "Test data.";
      fs.writeFileSync("/tmp/test.partition.key.date.log", record + "\n");
      kinesis.waitFor("streamExists", {
          StreamName: "test.partition.key.date"
        }).promise()
        .then(getShardIterator.bind(this, "test.partition.key.date"))
        .then(getRecords.bind(this))
        .then(readRecords.bind(this))
        .then((data) => {
          const records = data.Records;
          assert.equal(records.length, 1, "Expected a single message to be published.");
          assert.equal(Buffer.from(records[0].Data, "base64").toString("utf8"), record, "Received record data was not the same.");
          assert.equal(typeof Date.parse(records[0].PartitionKey), "number", "PartitionKey was not expected.");
          done();
        })
        .catch((err) => {
          console.error(err);
        });
    });
  });
});
