module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Ports exposing (resultDecoder, GraphQLResult)
import Api exposing (getAllTasks, decodeAllTasksResponse, markTaskDone, markTaskNotDone, decodeUpdateTaskResponse)
import TodoTask exposing (TodoTask, TaskId)
import Set exposing (Set)
import Json.Decode exposing (Value, decodeValue)
import Task


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { message : String
    , tasks : List TodoTask
    , pendingTaskUpdates : Set TaskId
    }


type Msg
    = SocketStart String
    | SocketResult Value
    | SocketError String
    | SocketAbort String
    | SocketCancel String
    | MarkTaskDone TaskId
    | MarkTaskNotDone TaskId
    | TaskUpdateFinished TaskId


init : ( Model, Cmd Msg )
init =
    ( { message = "", tasks = [], pendingTaskUpdates = Set.empty }, getAllTasks )


updateWithResult : Model -> GraphQLResult -> ( Model, Cmd Msg )
updateWithResult model result =
    case result.id of
        "GetAllTasks" ->
            case (decodeAllTasksResponse result.data) of
                Ok tasks ->
                    ( { model | message = "", tasks = tasks }, Cmd.none )

                Err msg ->
                    ( { model | message = "Error decoding result " ++ result.data ++ " : " ++ msg }, Cmd.none )

        "UpdateTask" ->
            case (decodeUpdateTaskResponse result.data) of
                Ok task ->
                    ( { model | message = "" }, (Task.perform TaskUpdateFinished) <| Task.succeed task.id )

                Err msg ->
                    ( { model | message = "Error decoding result " ++ result.data ++ " : " ++ msg }, Cmd.none )

        _ ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SocketStart data ->
            ( { model | message = "SocketStart: " ++ data }, Cmd.none )

        SocketResult data ->
            case (decodeValue resultDecoder data) of
                Ok result ->
                    updateWithResult model result

                Err msg ->
                    ( { model | message = "Error decoding result: " ++ msg }, Cmd.none )

        SocketAbort data ->
            ( { model | message = "SocketAbort: " ++ data }, Cmd.none )

        SocketError data ->
            ( { model | message = "SocketError: " ++ data }, Cmd.none )

        SocketCancel data ->
            ( { model | message = "SocketCancel: " ++ data }, Cmd.none )

        MarkTaskDone taskId ->
            ( { model | pendingTaskUpdates = Set.insert taskId model.pendingTaskUpdates }, markTaskDone taskId )

        MarkTaskNotDone taskId ->
            ( { model | pendingTaskUpdates = Set.insert taskId model.pendingTaskUpdates }, markTaskNotDone taskId )

        TaskUpdateFinished taskId ->
            ( { model | pendingTaskUpdates = Set.remove taskId model.pendingTaskUpdates }, Cmd.none )


isPending : Model -> TodoTask -> Bool
isPending model task =
    Set.member task.id model.pendingTaskUpdates


view : Model -> Html Msg
view model =
    let
        tasks =
            List.map taskItem model.tasks

        taskItem task =
            li
                []
                [ input
                    [ type_ "checkbox"
                    , checked task.done
                    , disabled (isPending model task)
                    , onClick
                        (case task.done of
                            True ->
                                MarkTaskNotDone task.id

                            False ->
                                MarkTaskDone task.id
                        )
                    ]
                    []
                , text task.description
                ]
    in
        div [ class "bg-grey-light" ]
            [ div
                [ class "container mx-auto py-3 px-4 shadow min-h-screen bg-white" ]
                [ h1 [] [ text "To do:" ]
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
        , Ports.socketCancel SocketCancel
        ]
