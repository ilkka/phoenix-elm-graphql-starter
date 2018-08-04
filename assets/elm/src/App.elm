module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Ports
import GraphQL.Request.Builder as GQL


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


type alias TodoTask =
    { id : Int
    , description : String
    , done : Bool
    }


tasksQuery : GQL.Document GQL.Query (List TodoTask) {}
tasksQuery =
    let
        task =
            GQL.object TodoTask
                |> GQL.with (GQL.field "id" [] GQL.int)
                |> GQL.with (GQL.field "description" [] GQL.string)
                |> GQL.with (GQL.field "done" [] GQL.bool)

        queryRoot =
            GQL.extract
                (GQL.field "allTasks" [] (GQL.list task))
    in
        GQL.queryDocument queryRoot


allTasksRequest : GQL.Request GQL.Query (List TodoTask)
allTasksRequest =
    GQL.request {} tasksQuery


type Msg
    = Increase
    | Decrease
    | SocketStart String
    | SocketResult String
    | SocketError String
    | SocketAbort String


init : ( Model, Cmd Msg )
init =
    ( { counter = 0, message = "" }, Ports.push (GQL.requestBody allTasksRequest) )


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
            ( { model | message = "SocketResult: " ++ data }, Cmd.none )

        SocketAbort data ->
            ( { model | message = "SocketAbort: " ++ data }, Cmd.none )

        SocketError data ->
            ( { model | message = "SocketError: " ++ data }, Cmd.none )


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
    Sub.batch
        [ Ports.socketStart SocketStart
        , Ports.socketResult SocketResult
        , Ports.socketAbort SocketAbort
        , Ports.socketError SocketError
        ]
