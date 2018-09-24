# elm-update-extra

This is a simple collection of functions for working with the `update` function
within the paradigm of a pipeline.  It includes functions to recursively call
update (including with a list of messages), update the model and add commands.

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
      DoSomething ->
          (model, Cmd.none)
              |> Update.andThen (update DoSomethingElse)
              |> Update.sequence [ DoAnotherThing, DoThatThing ]
              |> Update.addCmd (log "I did all kinds of things"
              |> Update.updateModel (\m -> { m | x = m.x + 1 }
```
