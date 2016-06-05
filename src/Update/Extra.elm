module Update.Extra exposing
  ( pipeUpdate
  , andThen
  , filter
  , addCmd
  , sequence
  )

{-| Convenience functions for working with effects in Elm

@docs pipeUpdate
@docs andThen
@docs filter
@docs addCmd
@docs sequence
-}

{-| A function allowing you to compose calls to update.  Most useful when used
in its infix form to make an update pipeline.

    import Update.Extra.Infix exposing ((:>))

    update : Msg -> Model -> (Model, Cmd Msg)
    update msg model =
      ComposedMsg ->
        (model, Cmd.none)
          :> update AnotherMsg
          :> update YetAnotherMsg
          :> update SubComponent.SomeMsg

-}
pipeUpdate : (m, Cmd a) -> (m -> (m, Cmd a)) -> (m, Cmd a)
pipeUpdate (model, cmd) f =
  let
    (model', cmd') = f model
  in
  (model', Cmd.batch [ cmd, cmd' ])

{-| Allows update call composition. Identical to [`pipeUpdate`](#pipeUpdate),
but with reversed arguments to be able to use it with the pipeline operator (`|>`)

For example:
```elm
update msg model =
  model ! []
    |> andThen update SomeMessage
    |> andThen update SomeOtherMessage
    ...
```
-}
andThen : (msg -> model -> (model, Cmd msg)) -> msg -> (model, Cmd msg) -> (model, Cmd msg)
andThen update = update >> flip pipeUpdate

{-| Allows you to conditionally trigger updates based on a predicate. Can be
used with the pipeline operator.

For example:
```elm
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
```

If you want to the pipeline operator in the nested pipeline, consider a lambda:
```elm
...
|> filter (i > 10)
  ( \state -> state
      |> andThen update BiggerThanTen
      |> andThen update AnotherMessage
      |> andThen update EvenMoreMessages
  )
|> andThen (update AlwaysTriggeredAfterPredicate)
```
-}
filter : Bool -> ((model, Cmd msg) -> (model, Cmd msg)) -> ((model, Cmd msg) -> (model, Cmd msg))
filter pred f =
  if pred then
    f
  else
    identity

{-| allows you to attach a Cmd to an update pipeline.

```elm
update msg model = model ! []
  |> andThen update AMessage
  |> addCmd doSomethingWithASideEffect
```
-}
addCmd : Cmd msg -> (model, Cmd msg) -> (model, Cmd msg)
addCmd cmd' (model, cmd) = (model, Cmd.batch [cmd, cmd'])

{-| allows you to attach multiple messages to an update at once.

```elm
sequence msg model = model ! []
  |> batch update
    [ AMessage
    , AnotherMessage
    , AThirdMessage
    ]
```
-}
sequence : (msg -> model -> (model, Cmd msg)) -> List msg -> (model, Cmd msg) -> (model, Cmd msg)
sequence update msgs init =
  let
    foldUpdate = andThen update
  in
    List.foldl foldUpdate init msgs
