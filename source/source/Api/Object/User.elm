-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.User exposing (..)

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


{-| ユーザーを識別するためのID
-}
id : SelectionSet String Api.Object.User
id =
    Object.selectionForField "String" "id" [] Decode.string


{-| 時間割表に登録した授業
-}
classInTimeTable : SelectionSet decodesTo Api.Object.ClassOfWeek -> SelectionSet decodesTo Api.Object.User
classInTimeTable object_ =
    Object.selectionForCompositeField "classInTimeTable" [] object_ identity


{-| ユーザーのプロフィール画像
-}
imageFileHash : SelectionSet Api.ScalarCodecs.FileHash Api.Object.User
imageFileHash =
    Object.selectionForField "ScalarCodecs.FileHash" "imageFileHash" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecFileHash |> .decoder)


{-| ユーザー名 LINEから引き継ぐ
-}
name : SelectionSet String Api.Object.User
name =
    Object.selectionForField "String" "name" [] Decode.string
