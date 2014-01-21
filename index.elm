import Input as I
import open Generator
import open Generator.Standard
import Native.Error
import open Shuffle
import open Data.List

debug : Bool
debug = False

-- provides a tuple of div and mod
divMod : Int -> Int -> (Int, Int)
divMod n d = (div n d, mod n d)

-- raise an error message
error msg = Native.Error.raise msg

-- lookup a key from a key-value list
lookup : a -> [(a,b)] -> Maybe b
lookup key kvs =
  if | kvs == [] -> Nothing
     | otherwise -> let
                      (k,v) = head kvs
                    in
                      if (key == k) then (Just v) else (lookup key (tail kvs))

-- Model
type Model = { state: [(Int, Bool)], generator: Generator Standard }

-- the initial state of the model
model : Model
model = 
  let
    seed = 0           -- TODO: The model always starts in the same state due to a static seed. The seed should be non-static.
    (val, generator') = int32Range (0, 15) (generator seed)
  in
    { state=(change val allSad), generator=generator' }

-- all combinations of people and moods
allMoods : [(Int, Bool)]
allMoods = concatMap (\i -> [(i, False), (i, True)]) [0..15]

-- all sad moods
allSad : [(Int, Bool)]
allSad = map (\i -> (i, False)) [0..15]

-- Update
-- changes the mood at index n
change n moods =
  let
    switcher (i, m) = if (i == n) then (i, not m) else (i, m)
  in
    map (switcher) moods

-- selects the face at position n, if correct, the faces shuffle and a different happy face is set
select : Int -> Model -> Model
select n model =
  case (lookup n model.state) of
    Nothing -> model
    (Just False) -> model
    (Just True) -> let
                     (state', generator') = shuffle allSad model.generator
                     (val, generator'') = int32Range (0, 15) generator'
                     state'' = change val state'
                   in
                     { state=state'', generator=generator'' }

-- represents a step in changing the model due to a signal
step : Maybe Int -> Model -> Model
step m model = case (m) of
                 Nothing -> error "No n supplied"
                 (Just n) -> select n model

-- Display
size : Int
size = 150

-- creates an image from a url (partially applied)
img : String -> Element
img = fittedImage size size

-- creates an image url from the index and mood
imgUrl : Int -> Bool -> String
imgUrl i happy = 
  let
    name = if happy then "happy" else "sad"
  in
    ("/img/" ++ (show i) ++ "_" ++ name ++ ".png")

-- creates a face button
face : (Int, Bool) -> Element
face (i, happy) = 
  let
    e = img (imgUrl i happy)
  in
    faceButton.button (Just i) e

-- creates all the face button elements from the provided mood state
faces : [(Int, Bool)] -> [Element]
faces moods = map (face) moods

-- creates a n-element wide table
grid : Int -> [Element] -> Element
grid n elems =
  let
    ess = chunk n elems
    acrosses = map (\es -> flow right es) ess
    downs = flow down acrosses
  in
    downs

-- renders the model into elements for display
render : Model -> Element
render model = 
  let 
    g = grid 4 (faces model.state)
    allImageCache = map (\(i,h) -> fittedImage 0 0 (imgUrl i h)) allMoods
    elements = allImageCache ++ [g]
  in
    if (not debug) 
    then flow down elements
    else flow down (elements ++ [asText model.state])

-- provides the event for all faceButtons to group their events and tie their id to the event
faceButton : { events : Signal (Maybe Int)
             , button : Maybe Int -> Element -> Element }
faceButton = I.buttons Nothing

-- represents the input to the system
input : Signal (Maybe Int)
input = faceButton.events

-- the main application entry point
main : Signal Element
main = lift render (foldp step model input)
