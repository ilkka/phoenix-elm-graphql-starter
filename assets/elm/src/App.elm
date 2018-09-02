module App exposing (..)

import Html as H exposing (Html)
import Html.Attributes as A
import Html.Events as Events
import Ports
import Todo
import Set exposing (Set)
import Task
import Json.Decode as D


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { message : String
    , tasks : List Todo.TodoTask
    , pendingTaskUpdates : Set Todo.TaskId
    }


type Msg
    = SocketStart String
    | SocketError String
    | SocketAbort String
    | SocketCancel String
    | GraphQLMessage Ports.GraphQLResult
    | MarkTaskDone Todo.TaskId
    | MarkTaskNotDone Todo.TaskId
    | TaskUpdateFinished Todo.TaskId


init : ( Model, Cmd Msg )
init =
    ( { message = "", tasks = [], pendingTaskUpdates = Set.empty }, Todo.getAllTasks )


updateWithResult : Model -> Ports.GraphQLResult -> ( Model, Cmd Msg )
updateWithResult model result =
    case Todo.decode result of
        Ok (Todo.GetAllTasks tasks) ->
            ( { model | message = "", tasks = tasks }, Cmd.none )

        Ok (Todo.UpdateTask task) ->
            let
                ( match, rest ) =
                    List.partition sameId model.tasks

                sameId : Todo.TodoTask -> Bool
                sameId task_ =
                    task.id == task_.id

                newTasks =
                    [ task ] ++ rest

                cmd =
                    (Task.perform TaskUpdateFinished) <| Task.succeed task.id
            in
                ( { model | tasks = newTasks, message = "" }, cmd )

        Err msg ->
            ( { model | message = "Error decoding result " ++ result.data ++ " : " ++ msg }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SocketStart data ->
            ( model, Cmd.none )

        GraphQLMessage result ->
            updateWithResult model result

        SocketAbort data ->
            ( { model | message = "SocketAbort: " ++ data }, Cmd.none )

        SocketError data ->
            ( { model | message = "SocketError: " ++ data }, Cmd.none )

        SocketCancel data ->
            ( { model | message = "SocketCancel: " ++ data }, Cmd.none )

        MarkTaskDone taskId ->
            ( (markPending model taskId), Todo.markTaskDone taskId )

        MarkTaskNotDone taskId ->
            ( (markPending model taskId), Todo.markTaskNotDone taskId )

        TaskUpdateFinished taskId ->
            ( (unmarkPending model taskId), Cmd.none )


markPending : Model -> Todo.TaskId -> Model
markPending model taskId =
    { model | pendingTaskUpdates = Set.insert taskId model.pendingTaskUpdates }


unmarkPending : Model -> Todo.TaskId -> Model
unmarkPending model taskId =
    { model | pendingTaskUpdates = Set.remove taskId model.pendingTaskUpdates }


isPending : Model -> Todo.TodoTask -> Bool
isPending model task =
    Set.member task.id model.pendingTaskUpdates


view : Model -> Html Msg
view model =
    let
        undoneFirstAlphabetical : Todo.TodoTask -> Todo.TodoTask -> Order
        undoneFirstAlphabetical a b =
            case ( a.done, b.done ) of
                ( False, True ) ->
                    LT

                ( True, False ) ->
                    GT

                _ ->
                    compare a.description b.description

        sortedTasks =
            List.sortWith undoneFirstAlphabetical model.tasks

        taskItems =
            List.map taskItem sortedTasks

        taskItem task =
            H.li
                []
                [ H.input
                    [ A.type_ "checkbox"
                    , A.checked task.done
                    , A.disabled (isPending model task)
                    , Events.onWithOptions
                        "click"
                        { stopPropagation = True
                        , preventDefault = True
                        }
                        (D.succeed
                            (case task.done of
                                True ->
                                    MarkTaskNotDone task.id

                                False ->
                                    MarkTaskDone task.id
                            )
                        )
                    ]
                    []
                , H.text task.description
                ]

        newTaskInput =
            H.li
                []
                [ H.input
                    [ A.type_ "text"
                    , A.class "border border-grey-dark"
                    ]
                    []
                ]
    in
        H.div [ A.class "bg-grey-light" ]
            [ H.div
                [ A.class "container mx-auto py-3 px-4 shadow min-h-screen bg-white" ]
                [ H.h1 [] [ H.text "To do:" ]
                , H.div [] [ H.text model.message ]
                , H.ul [] (taskItems ++ [ newTaskInput ])
                ]
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.socketStart SocketStart
        , Ports.receive GraphQLMessage
        , Ports.socketAbort SocketAbort
        , Ports.socketError SocketError
        , Ports.socketCancel SocketCancel
        ]
