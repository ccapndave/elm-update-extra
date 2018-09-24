module Update.Extra exposing
    ( andThen
    , filter
    , updateModel
    , addCmd
    , mapCmd
    , sequence
    )

{-| Convenience functions for working with updates in Elm

@docs andThen
@docs filter
@docs updateModel
@docs addCmd
@docs mapCmd
@docs sequence

-}


{-| Allows update call composition. Can be used with the pipeline operator (|>)
to chain updates.

For example:

    update msg model =
      ( model, Cmd.none )
        |> andThen update SomeMessage
        |> andThen update SomeOtherMessage
        |> andThen update (MessageWithArguments "Hello")
        ...

-}
andThen : (msg -> model -> ( model, Cmd a )) -> msg -> ( model, Cmd a ) -> ( model, Cmd a )
andThen update msg ( model, cmd ) =
    let
        ( model_, cmd_ ) =
            update msg model
    in
    ( model_, Cmd.batch [ cmd, cmd_ ] )


{-| Allows you to conditionally trigger updates based on a predicate. Can be
used with the pipeline operator.

For example:

    update msg model =
        case msg of
            SomeMessage i ->
                ( model, Cmd.none )
                    |> filter (i > 10)
                        (andThen update BiggerThanTen
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
filter : Bool -> (( model, Cmd msg ) -> ( model, Cmd msg )) -> (( model, Cmd msg ) -> ( model, Cmd msg ))
filter pred f =
    if pred then
        f

    else
        Basics.identity


{-| Allows you to update the model in an update pipeline.

For example

    update msg model = model ! []
      |> updateModel \model -> { model | a = 1 }
      |> updateModel \model -> { model | b = 2 }

-}
updateModel : (model -> model) -> ( model, Cmd msg ) -> ( model, Cmd msg )
updateModel f ( model, cmd ) =
    ( f model, cmd )


{-| Allows you to attach a Cmd to an update pipeline.

For example:

    update msg model =
        ( model, Cmd.none )
            |> andThen update AMessage
            |> addCmd doSomethingWithASideEffect

-}
addCmd : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
addCmd cmd_ ( model, cmd ) =
    ( model, Cmd.batch [ cmd, cmd_ ] )


{-| Map over the Cmd in an update pipeline
-}
mapCmd : (msg -> msg_) -> ( model, Cmd msg ) -> ( model, Cmd msg_ )
mapCmd tagger ( model, cmd ) =
    ( model, cmd |> Cmd.map tagger )


{-| Allows you to attach multiple messages to an update at once.

For example:

    update msg model =
        ( model, Cmd.none )
            |> sequence update
                [ AMessage
                , AnotherMessage
                , AThirdMessage
                ]

-}
sequence : (msg -> model -> ( model, Cmd a )) -> List msg -> ( model, Cmd a ) -> ( model, Cmd a )
sequence update msgs init =
    let
        foldUpdate =
            andThen update
    in
    List.foldl foldUpdate init msgs
