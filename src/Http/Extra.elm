module Http.Extra exposing
    ( mockFailDecoderError
    , mockFailNetworkError
    , mockSuccess
    )

import Http
import Process
import Task


mockSuccess : a -> (Result Http.Error a -> msg) -> Cmd msg
mockSuccess value toMsg =
    emitWithDelay (toMsg (Ok value))


mockFailNetworkError : (Result Http.Error a -> msg) -> Cmd msg
mockFailNetworkError toMsg =
    emitWithDelay (toMsg (Err Http.NetworkError))


mockFailDecoderError : (Result Http.Error a -> msg) -> Cmd msg
mockFailDecoderError toMsg =
    emitWithDelay
        (toMsg (Err <| Http.BadBody (Debug.todo "flesh this out")))


emitWithDelay : msg -> Cmd msg
emitWithDelay msg =
    let
        _ =
            Debug.log "mock request" msg
    in
    Process.sleep 1000
        |> Task.perform (\() -> Debug.log "mock response" msg)
