module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Ports exposing (sendData, receiveData)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { counter : Int
    , message : String
    }


type Msg
    = Increase
    | Decrease
    | BacktalkFromJS String


init : ( Model, Cmd Msg )
init =
    ( { counter = 0, message = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increase ->
            ( { model | counter = model.counter + 1 }, sendData "Increased" )

        Decrease ->
            ( { model | counter = model.counter - 1 }, sendData "Decreased" )

        BacktalkFromJS data ->
            ( { model | message = data }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "bg-grey-light" ]
        [ div
            [ class "container mx-auto py-3 px-4 shadow min-h-screen bg-white" ]
            [ button
                [ onClick Increase
                , class "bg-blue rounded text-white font-bold w-10 h-10 hover:bg-blue-dark"
                ]
                [ text "+" ]
            , span [ class "inline-block w-12 text-xl text-center" ] [ text (toString model.counter) ]
            , button
                [ onClick Decrease
                , class "bg-blue rounded text-white font-bold w-10 h-10 hover:bg-blue-dark"
                ]
                [ text "-" ]
            , div [] [ text model.message ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveData BacktalkFromJS
