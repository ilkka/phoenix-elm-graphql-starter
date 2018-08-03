port module Ports exposing (..)


port sendData : String -> Cmd msg


port receiveData : (String -> msg) -> Sub msg
