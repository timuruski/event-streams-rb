# Event Streams

This is a repo for playing with event streams in Ruby.

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
