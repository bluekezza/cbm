{- Code derived from https://github.com/maxsnew/Scramble/blob/master/Input.elm -}
module Input (buttons)
       where
import Graphics.Input as I
import Mouse
import Maybe as M
import open Core

const : a -> b -> a
const x y = x

fromJust x = case x of
  Just y -> y
  Nothing -> error "Nothing received in fromJust"

justs : a -> Signal (Maybe a) -> Signal a
justs x s = fromJust <~ (keepIf M.isJust (Just x) s)

buttons : a -> { events : Signal a
               , button : a -> Element -> Element }
buttons def = let hovs = I.hoverables (Just def)
              in { events = justs def . keepWhen Mouse.isDown (Just def) <| hovs.events
                 , button = \v -> hovs.hoverable (\b -> if b
                                                        then Just v
                                                        else Nothing)
                 }