module Http.Extra exposing
    (  mockFailBadRequestError
       --, TODO mockFailDecoderError

    , mockFailNetworkError
    , mockSuccess
    )

import Http
import Process
import Task


mockSuccess : Float -> a -> (Result Http.Error a -> msg) -> Cmd msg
mockSuccess delay value toMsg =
    emitWithDelay delay
        (toMsg (Ok value))


mockFailNetworkError : Float -> (Result Http.Error a -> msg) -> Cmd msg
mockFailNetworkError delay toMsg =
    emitWithDelay delay
        (toMsg (Err Http.NetworkError))


mockFailBadRequestError : Float -> (Result Http.Error a -> msg) -> Cmd msg
mockFailBadRequestError delay toMsg =
    emitWithDelay delay
        (toMsg (Err <| Http.BadStatus 400))


emitWithDelay : Float -> msg -> Cmd msg
emitWithDelay delay msg =
    let
        _ =
            Debug.log "mock request" msg
    in
    Process.sleep delay
        |> Task.perform (\() -> Debug.log "mock response" msg)
