module Cmd.Extra exposing (andThen)


andThen : (model -> ( model, Cmd msg )) -> ( model, Cmd msg ) -> ( model, Cmd msg )
andThen fn ( oldModel, oldCmd ) =
    let
        ( newModel, additionalCmd ) =
            fn oldModel
    in
    ( newModel
    , Cmd.batch [ oldCmd, additionalCmd ]
    )
