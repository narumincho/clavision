-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Scalar exposing (Codecs, FileHash(..), Url(..), defaultCodecs, defineCodecs, unwrapCodecs, unwrapEncoder)

import Graphql.Codec exposing (Codec)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type FileHash
    = FileHash String


type Url
    = Url String


defineCodecs :
    { codecFileHash : Codec valueFileHash
    , codecUrl : Codec valueUrl
    }
    -> Codecs valueFileHash valueUrl
defineCodecs definitions =
    Codecs definitions


unwrapCodecs :
    Codecs valueFileHash valueUrl
    ->
        { codecFileHash : Codec valueFileHash
        , codecUrl : Codec valueUrl
        }
unwrapCodecs (Codecs unwrappedCodecs) =
    unwrappedCodecs


unwrapEncoder getter (Codecs unwrappedCodecs) =
    (unwrappedCodecs |> getter |> .encoder) >> Graphql.Internal.Encode.fromJson


type Codecs valueFileHash valueUrl
    = Codecs (RawCodecs valueFileHash valueUrl)


type alias RawCodecs valueFileHash valueUrl =
    { codecFileHash : Codec valueFileHash
    , codecUrl : Codec valueUrl
    }


defaultCodecs : RawCodecs FileHash Url
defaultCodecs =
    { codecFileHash =
        { encoder = \(FileHash raw) -> Encode.string raw
        , decoder = Object.scalarDecoder |> Decode.map FileHash
        }
    , codecUrl =
        { encoder = \(Url raw) -> Encode.string raw
        , decoder = Object.scalarDecoder |> Decode.map Url
        }
    }