# Event Streams

This is a repo for playing with event streams in Ruby.

EventBus -> Topic -> Stream -> Handler
Repository (handler) -> Stream -> Topic -> EventBus

There is a tiny API server built on Sinatra:
```
$ rackup -D

$ curl localhost:9292/users/1
> Not found

$ curl localhost:9292/users -d "name=Alice" -d "email=alice@example.org"
> {"id":1,"email":"alice@example.org","name":"Alice"}

$ curl localhost:9292/users/1
> {"id":1,"email":"alice@example.org","name":"Alice"}

$ curl -X DELETE localhost:9292/users/1
> {"id":1,"email":"alice@example.org","name":"Alice"}

$ curl localhost:9292/users/1
> Not found
```

## Notes

EventBus:
  - Organizes events into topics.
  - Ordered sequence of events.
  - De-duplicates produced events.

EventStream:
  - Filters events from a specific topic.
  - Maintains event cursor.

Subscription:
  - Joins a handler to an EventStream.
  - De-duplicates received events.

Stream (sequence of events) -> Topic (subset of events) -> Subscription (topic + handler)

Stream, linear sequence of events, handles de-duplication.

Topic, selects a subset of events, handles subscribing and publishing.
Is the label part of the event or separate?
What does it mean to publish an event to the "all events" topic?
How to handle aggregate topics though? Subscribing merges events, but how does publishing work?
Are events published multiple times? The topic labels are preserved in the stream.

Subscription, combines a handler with a topic.

Handler, receives events and routes them to a state.

Resources:
https://nsq.io/overview/design.html
https://livebook.manning.com/book/event-streams-in-action
