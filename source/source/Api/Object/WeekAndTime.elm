-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.WeekAndTime exposing (..)

import Api.Enum.Time
import Api.Enum.Week
import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.ScalarCodecs
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


{-| 曜日
-}
week : SelectionSet Api.Enum.Week.Week Api.Object.WeekAndTime
week =
    Object.selectionForField "Enum.Week.Week" "week" [] Api.Enum.Week.decoder


{-| 時限
-}
time : SelectionSet Api.Enum.Time.Time Api.Object.WeekAndTime
time =
    Object.selectionForField "Enum.Time.Time" "time" [] Api.Enum.Time.decoder
