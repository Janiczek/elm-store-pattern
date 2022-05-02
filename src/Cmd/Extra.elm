module Cmd.Extra exposing (andThen, andThenMaybe)


andThen :
    (model -> ( model, Cmd msg ))
    -> ( model, Cmd msg )
    -> ( model, Cmd msg )
andThen fn ( oldModel, oldCmd ) =
    let
        ( newModel, additionalCmd ) =
            fn oldModel
    in
    ( newModel
    , Cmd.batch [ oldCmd, additionalCmd ]
    )


andThenMaybe :
    (a -> model -> ( model, Cmd msg ))
    -> Maybe a
    -> ( model, Cmd msg )
    -> ( model, Cmd msg )
andThenMaybe fn maybe modelAndCmd =
    case maybe of
        Nothing ->
            modelAndCmd

        Just thing ->
            modelAndCmd
                |> andThen (fn thing)
