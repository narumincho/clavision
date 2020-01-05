-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Mutation exposing (..)

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
import Json.Decode as Decode exposing (Decoder)


{-| 新規登録かログインするためのURLを得る。受け取ったURLをlocation.hrefに代入するとかして、各サービスの認証画面へ
-}
getLineLoginUrl : SelectionSet Api.ScalarCodecs.Url RootMutation
getLineLoginUrl =
    Object.selectionForField "ScalarCodecs.Url" "getLineLoginUrl" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecUrl |> .decoder)


type alias SetClassOptionalArguments =
    { classId : OptionalArgument String }


type alias SetClassRequiredArguments =
    { accessToken : String
    , week : Api.Enum.Week.Week
    , time : Api.Enum.Time.Time
    }


{-| 時間割に授業を登録する

  - accessToken - アクセストークン
  - week - 曜日
  - time - 時限
  - classId - 授業ID。nullで指定なしにできる

-}
setClass : (SetClassOptionalArguments -> SetClassOptionalArguments) -> SetClassRequiredArguments -> SelectionSet decodesTo Api.Object.User -> SelectionSet decodesTo RootMutation
setClass fillInOptionals requiredArgs object_ =
    let
        filledInOptionals =
            fillInOptionals { classId = Absent }

        optionalArgs =
            [ Argument.optional "classId" filledInOptionals.classId Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "setClass" (optionalArgs ++ [ Argument.required "accessToken" requiredArgs.accessToken Encode.string, Argument.required "week" requiredArgs.week (Encode.enum Api.Enum.Week.toString), Argument.required "time" requiredArgs.time (Encode.enum Api.Enum.Time.toString) ]) object_ identity