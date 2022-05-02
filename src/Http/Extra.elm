module Http.Extra exposing
    ( mockFailDecoderError
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


mockFailDecoderError : Float -> (Result Http.Error a -> msg) -> Cmd msg
mockFailDecoderError delay toMsg =
    emitWithDelay delay
        (toMsg (Err <| Http.BadBody (Debug.todo "flesh this out")))


emitWithDelay : Float -> msg -> Cmd msg
emitWithDelay delay msg =
    let
        _ =
            Debug.log "mock request" msg
    in
    Process.sleep delay
        |> Task.perform (\() -> Debug.log "mock response" msg)
