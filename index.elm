import Input as I
import Generator (Generator, int32Range)
import Generator.Standard (Standard, generator)
import Shuffle (shuffle)
import Data.List (chunk)
import Core (error, divMod, lookup, startSignal)

debug : Bool
debug = False

-- Model
type Model = { init: Bool
             , state: [(Int, Bool)]
             , generator: Generator Standard
             }

-- the initial state of the model
initialState : Model
initialState = { init=False
               , state=[]
               , generator=generator 0
               }

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
                     { model | state <- state''
                             , generator <- generator'' }

-- represents a step in changing the model due to a signal
step : (FaceSelection, (Time, Int)) -> Model -> Model
step (mSelection, (tStart, _)) model = 
  let
    m = model
    -- initialize the model if empty
    model' = case (m.init) of
               True -> case (mSelection) of
                         (Just selection) -> select selection m
                         Nothing -> error "No selection supplied"
               False -> let
                          n = 0
                          m' = { m | init <- True
                                   , state <- (change n allSad)
                                   , generator <- (generator (round tStart)) 
                               }
                        in
                          select n m'
  in
    model'

-- Display

-- the dimensions of the faces
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
    ("img/" ++ (show i) ++ "_" ++ name ++ ".png")

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
-- includes an imageCache so that the browser downloads all images, to ensure there is not a delay when a new happy face appears
display : Model -> Element
display model = 
  let
    g = grid 4 (faces model.state)
    allImageCache = map (\(i,h) -> fittedImage 0 0 (imgUrl i h)) allMoods
    elements = allImageCache ++ [g]
  in
    if (not debug) 
    then flow down elements
    else flow down (elements ++ [asText model])

-- provides the event for all faceButtons to group their events and tie their id to the event
type FaceSelection = Maybe Int
faceButton : { events : Signal FaceSelection
             , button : Maybe Int -> Element -> Element }
faceButton = I.buttons Nothing

-- represents the input to the system
input : Signal (FaceSelection, (Time, Int))
input = lift2 (,) faceButton.events (timestamp startSignal)

-- the main application entry point
main : Signal Element
main = lift display (foldp step initialState input)