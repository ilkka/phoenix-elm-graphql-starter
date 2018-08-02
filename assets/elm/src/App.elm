module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


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
    div [ class "bg-grey-light" ]
        [ div
            [ class "container mx-auto px-4 shadow min-h-screen bg-white" ]
            [ button [ onClick Increase ] [ text "+" ]
            , text (toString model)
            , button [ onClick Decrease ] [ text "-" ]
            ]
        ]
