module App exposing (..)

import Html exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    Int


type Msg
    = Increase
    | Decrease


init : ( Model, Cmd Msg )
init =
    ( 0, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increase ->
            ( model + 1, Cmd.none )

        Decrease ->
            ( model - 1, Cmd.none )


view : Model -> Html Msg
view model =
    div [] [ text (toString model) ]
