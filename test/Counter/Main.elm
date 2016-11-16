module Counter.Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Update.Extra as Update
import Update.Extra.Infix exposing ((:>))
import Task
import Debug


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    { count : Int
    , n : Int
    }


type Msg
    = NoOp
    | Increment
    | Decrement
    | IncrementBy Int
    | DecrementBy Int
    | IncrementN
    | DecrementN
    | IncrementBy_ Int


init : ( Model, Cmd Msg )
init =
    ( Model
        0
        10
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


debug : String -> Cmd Msg
debug msg =
    Task.perform (always NoOp) (Task.succeed (Debug.log "" msg))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Increment ->
            { model | count = model.count + 1 } ! []

        Decrement ->
            { model | count = model.count - 1 } ! []

        IncrementN ->
            { model | n = model.n + 1 }
                ! []
                |> Update.addCmd (debug "incrementing n")

        DecrementN ->
            { model | n = model.n - 1 }
                ! []
                |> Update.addCmd (debug "decrementing n")

        IncrementBy n ->
            ( model, Cmd.none )
                |> Update.filter (n > 0)
                    (\state ->
                        state
                            |> Update.andThen update Increment
                            :> update (IncrementBy (n - 1))
                    )

        DecrementBy n ->
            let
                msgs =
                    if n > 0 then
                        [ Decrement, DecrementBy (n - 1) ]
                    else
                        []
            in
                ( model, Cmd.none )
                    |> Update.sequence update msgs

        IncrementBy_ n ->
            ( model, Cmd.none )
                |> Update.sequence update (List.repeat n Increment)


view : Model -> Html Msg
view model =
    div
        []
        [ labelledNumberView model.n "n: "
        , mkButton IncrementN "Increment n"
        , mkButton DecrementN "Decrement n"
        , labelledNumberView model.count "count: "
        , mkButton (IncrementBy model.n) "Increment"
        , mkButton (IncrementBy_ model.n) "Increment'"
        , mkButton (DecrementBy model.n) "Decrement"
        ]


labelledNumberView : Int -> String -> Html Msg
labelledNumberView amount label =
    div
        []
        [ text <| label ++ toString amount ]


mkButton : Msg -> String -> Html Msg
mkButton msg label =
    button
        [ onClick msg
        ]
        [ text label ]
