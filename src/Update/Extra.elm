module Update.Extra exposing
  ( andThen
  , filter
  , addCmd
  , sequence
  )

{-| Convenience functions for working with updates in Elm

@docs andThen
@docs filter
@docs addCmd
@docs sequence
-}

{-| Allows update call composition. Can be used with the pipeline operator (|>)
to chain updates.

For example:

    update msg model =
      model ! []
        |> andThen update SomeMessage
        |> andThen update SomeOtherMessage
        ...

The same can be achieved using `Update.Extra.Infix.(:>)`.

For example:

    import Update.Extra.Infix exposing ((:>))

    update msg model =
      model ! []
        :> update SomeMessage
        :> update SomeOtherMessage
-}
andThen : (msg -> model -> (model, Cmd msg)) -> msg -> (model, Cmd msg) -> (model, Cmd msg)
andThen update msg (model, cmd) =
  let
    (model', cmd') = update msg model
  in
    (model', Cmd.batch [cmd, cmd'])

{-| Allows you to conditionally trigger updates based on a predicate. Can be
used with the pipeline operator.

For example:

    update msg model =
      case msg of
        SomeMessage i ->
          model ! []
            |> filter (i > 10)
                (    andThen update BiggerThanTen
                  >> andThen update AnotherMessage
                  >> andThen update EvenMoreMessages
                )
            |> andThen (update AlwaysTriggeredAfterPredicate)

If you want use to the pipeline operator in the nested pipeline, consider a
lambda:

    |> filter (i > 10)
      ( \state -> state
          |> andThen update BiggerThanTen
          |> andThen update AnotherMessage
          |> andThen update EvenMoreMessages
      )
    |> andThen (update AlwaysTriggeredAfterPredicate)
-}
filter : Bool -> ((model, Cmd msg) -> (model, Cmd msg)) -> ((model, Cmd msg) -> (model, Cmd msg))
filter pred f =
  if pred then
    f
  else
    identity

{-| Allows you to attach a Cmd to an update pipeline.

For example:

    update msg model = model ! []
      |> andThen update AMessage
      |> addCmd doSomethingWithASideEffect
-}
addCmd : Cmd msg -> (model, Cmd msg) -> (model, Cmd msg)
addCmd cmd' (model, cmd) = (model, Cmd.batch [cmd, cmd'])

{-| Allows you to attach multiple messages to an update at once.

For example:

    update msg model = model ! []
      |> sequence update
        [ AMessage
        , AnotherMessage
        , AThirdMessage
        ]
-}
sequence : (msg -> model -> (model, Cmd msg)) -> List msg -> (model, Cmd msg) -> (model, Cmd msg)
sequence update msgs init =
  let
    foldUpdate = andThen update
  in
    List.foldl foldUpdate init msgs
