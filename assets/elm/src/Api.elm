module Api exposing (..)

import TodoTask exposing (TodoTask)
import GraphQL.Request.Builder exposing (..)
import Ports
import Json.Decode exposing (decodeString)


getAllTasks : Cmd msg
getAllTasks =
    Ports.push (requestBody allTasksRequest)


decodeAllTasksResponse : String -> Result String (List TodoTask)
decodeAllTasksResponse response =
    decodeString (responseDataDecoder allTasksRequest) response


tasksQuery : Document Query (List TodoTask) {}
tasksQuery =
    let
        task =
            object TodoTask
                |> with (field "id" [] string)
                |> with (field "description" [] string)
                |> with (field "done" [] bool)

        queryRoot =
            extract
                (field "allTasks" [] (list task))
    in
        queryDocument queryRoot


allTasksRequest : Request Query (List TodoTask)
allTasksRequest =
    request {} tasksQuery
