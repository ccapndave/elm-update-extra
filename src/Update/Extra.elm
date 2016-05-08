module Update.Extra exposing (..)

{-| Convenience functions for working with effects in Elm

@docs pipeUpdate
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
