module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Ports
import Api exposing (getAllTasks, decodeAllTasksResponse)
import TodoTask exposing (TodoTask)


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
    , tasks : List TodoTask
    }


type Msg
    = Increase
    | Decrease
    | SocketStart String
    | SocketResult String
    | SocketError String
    | SocketAbort String


init : ( Model, Cmd Msg )
init =
    ( { counter = 0, message = "", tasks = [] }, getAllTasks )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increase ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        Decrease ->
            ( { model | counter = model.counter - 1 }, Cmd.none )

        SocketStart data ->
            ( { model | message = "SocketStart: " ++ data }, Cmd.none )

        SocketResult data ->
            case (decodeAllTasksResponse data) of
                Ok tasks ->
                    ( { model | message = "SocketResult: " ++ data, tasks = tasks }, Cmd.none )

                Err msg ->
                    ( { model | message = "Error decoding " ++ data ++ ": " ++ msg, tasks = [] }, Cmd.none )

        SocketAbort data ->
            ( { model | message = "SocketAbort: " ++ data }, Cmd.none )

        SocketError data ->
            ( { model | message = "SocketError: " ++ data }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        tasks =
            List.map taskItem model.tasks

        taskItem task =
            li [] [ text task.description ]
    in
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
                , ul [] tasks
                ]
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.socketStart SocketStart
        , Ports.socketResult SocketResult
        , Ports.socketAbort SocketAbort
        , Ports.socketError SocketError
        ]
