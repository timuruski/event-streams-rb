# Event Streams

This is a repo for playing with event streams in Ruby.

Stream (sequence of events) -> Topic (subset of events) -> Subscription (topic + handler)

Stream, linear sequence of events, handles de-duplication.

Topic, selects a subset of events, handles subscribing and publishing.
Is the label part of the event or separate?
How to handle aggregate topics though? Subscribing merges events, but how does publishing work?
Are events published multiple times? The topic labels are preserved in the stream.

topic(a, b) -> publish(event) -> stream((event, a, b))
  topic(a) -> receive(event, a)
  topic(a) -> publish(event, a)
  topic(a, b) -> receive(event, a)
  topic(b) -> receive(event, a)
  topic(a, b) -> receive(event, a)

Subscription, combines a handler with a topic.

Handler, receives events and routes them to a state.
