module TodoRepo exposing (..)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Ports exposing (GraphQLResult)
import Json.Decode exposing (decodeString)
import Json.Encode exposing (null)
import Result


{-| Task ID
-}
type alias TaskId =
    String


{-| A task in our repository
-}
type alias TodoTask =
    { id : TaskId
    , description : String
    , done : Bool
    }


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


{-| Generate a command for sending a GraphQL query that gets all tasks.
-}
getAllTasks : Cmd msg
getAllTasks =
    let
        operation =
            requestBody allTasksQuery

        request =
            { tag = "GetAllTasks", operation = operation, variables = null }
    in
        Ports.send request


{-| Generate a command for sending a GraphQL mutation that marks a task
as done.
-}
markTaskDone : TaskId -> Cmd msg
markTaskDone taskId =
    updateTaskDone True taskId


{-| Generate a command for sending a GraphQL mutation that marks a task
as not done.
-}
markTaskNotDone : TaskId -> Cmd msg
markTaskNotDone taskId =
    updateTaskDone False taskId


{-| Generate a command for sending a GraphQL mutation that marks a task
as either done or not done.
-}
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


{-| Decode a JSON string that represents a reply to the all tasks
GraphQL query.
-}
decodeAllTasksResponse : String -> Result String (List TodoTask)
decodeAllTasksResponse response =
    response
        |> decodeString (responseDataDecoder allTasksQuery)


{-| The GraphQL query for getting all tasks.
-}
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


{-| This type represents an update to a single task's properties. In essence
it is a task with all fields except the ID wrapped in Maybe, allowing a partial
update.
-}
type alias TaskFields =
    { id : String
    , description : Maybe String
    , done : Maybe Bool
    }


{-| Decode a JSON string that represents a response to a task update.
-}
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


{-| Generate a GraphQL mutation for updating a task.
-}
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
