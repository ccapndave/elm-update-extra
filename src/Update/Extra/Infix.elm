module Update.Extra.Infix exposing (..)

{-| Infix versions of functions in Effects.Extra

@docs (:>)
-}

import Update.Extra exposing (pipeUpdate)

{-| An infix version of Update.Extra.pipeUpdate.  Easy to remember because the
colon in the symbol represents piping two things through the chain (model and commands!).
-}
(:>) : (m, Cmd a) -> (m -> (m, Cmd a)) -> (m, Cmd a)
(:>) = pipeUpdate

infixl 0 :>
