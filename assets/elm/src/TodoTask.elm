module TodoTask exposing (..)

type alias TaskId = String

type alias TodoTask =
    { id : TaskId
    , description : String
    , done : Bool
    }
