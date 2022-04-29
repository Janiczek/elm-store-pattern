module Http.Extra exposing (mockFail, mockSuccess)

import Http
import Process
import Task


mockSuccess : a -> (Result Http.Error a -> msg) -> Cmd msg
mockSuccess value toMsg =
    emitWithDelay (toMsg (Ok value))


mockFail : Http.Error -> (Result Http.Error a -> msg) -> Cmd msg
mockFail err toMsg =
    emitWithDelay (toMsg (Err err))


emitWithDelay : msg -> Cmd msg
emitWithDelay msg =
    Process.sleep 2000
        |> Task.perform (\() -> msg)
