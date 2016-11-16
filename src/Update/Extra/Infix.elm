module Update.Extra.Infix
    exposing
        ( (:>)
        )

{-| Infix versions of functions in Update.Extra

@docs (:>)
-}


{-| An infix version of Update.Extra.andThen.  Easy to remember because the
colon in the symbol represents piping two things through the chain (model and commands!).
-}
(:>) : ( model, Cmd msg ) -> (model -> ( model, Cmd msg )) -> ( model, Cmd msg )
(:>) =
    pipeUpdate
infixl 0 :>


pipeUpdate : ( model, Cmd msg ) -> (model -> ( model, Cmd msg )) -> ( model, Cmd msg )
pipeUpdate ( model, cmd ) update =
    let
        ( model_, cmd_ ) =
            update model
    in
        ( model_, Cmd.batch [ cmd, cmd_ ] )
