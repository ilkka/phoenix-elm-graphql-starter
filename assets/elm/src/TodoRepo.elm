module TodoRepo exposing (..)

import TodoTask exposing (TodoTask)
import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Ports exposing (GraphQLResult)
import Json.Decode exposing (decodeString)
import Json.Encode exposing (null)
import TodoTask exposing (TaskId)
import Result


{-| This type describes the different kinds of results that can
be delivered in response to todo operations.
-}
type TodoOperation
    = GetAllTasks (List TodoTask)
    | UpdateTask TodoTask


{-| Decode a GraphQL result into a typed result based on its tag.
-}
decode : GraphQLResult -> Result String TodoOperation
decode result =
    case result.tag of
        "GetAllTasks" ->
            Result.map GetAllTasks (decodeAllTasksResponse result.data)

        "UpdateTask" ->
            Result.map UpdateTask (decodeUpdateTaskResponse result.data)

        tag ->
            Err ("Unknown result tag " ++ tag)


getAllTasks : Cmd msg
getAllTasks =
    let
        operation =
            requestBody allTasksQuery

        request =
            { tag = "GetAllTasks", operation = operation, variables = null }
    in
        Ports.send request


markTaskDone : TaskId -> Cmd msg
markTaskDone taskId =
    updateTaskDone True taskId


markTaskNotDone : TaskId -> Cmd msg
markTaskNotDone taskId =
    updateTaskDone False taskId


updateTaskDone : Bool -> TaskId -> Cmd msg
updateTaskDone done taskId =
    let
        mutation =
            updateTaskMutation
                { id = taskId
                , done = Just done
                , description = Nothing
                }

        operation =
            requestBody mutation

        variables =
            jsonVariableValues mutation

        request =
            { tag = "UpdateTask"
            , operation = operation
            , variables =
                case variables of
                    Just vars ->
                        vars

                    Nothing ->
                        null
            }
    in
        Ports.send <| request


decodeAllTasksResponse : String -> Result String (List TodoTask)
decodeAllTasksResponse response =
    response
        |> decodeString (responseDataDecoder allTasksQuery)


allTasksQuery : Request Query (List TodoTask)
allTasksQuery =
    let
        task =
            object TodoTask
                |> with (field "id" [] id)
                |> with (field "description" [] string)
                |> with (field "done" [] bool)

        root =
            extract
                (field "allTasks" [] (list task))

        doc =
            namedQueryDocument "GetAllTasks" root
    in
        request {} doc


type alias TaskFields =
    { id : String
    , description : Maybe String
    , done : Maybe Bool
    }


decodeUpdateTaskResponse : String -> Result String TodoTask
decodeUpdateTaskResponse response =
    let
        emptyVars =
            { id = "", description = Nothing, done = Nothing }

        decode =
            decodeString <| responseDataDecoder <| updateTaskMutation emptyVars
    in
        response
            |> decode


updateTaskMutation : TaskFields -> Request Mutation TodoTask
updateTaskMutation fields =
    let
        taskIdVar =
            Var.required "id" .id Var.id

        descriptionVar =
            Var.optional "description" .description Var.string ""

        doneVar =
            Var.optional "done" .done Var.bool False

        task =
            object TodoTask
                |> with (field "id" [] id)
                |> with (field "description" [] string)
                |> with (field "done" [] bool)

        root =
            extract
                (field "updateTask"
                    [ ( "id", Arg.variable taskIdVar )
                    , ( "description", Arg.variable descriptionVar )
                    , ( "done", Arg.variable doneVar )
                    ]
                    task
                )

        doc : Document Mutation TodoTask TaskFields
        doc =
            namedMutationDocument "UpdateTask" root
    in
        request fields doc
