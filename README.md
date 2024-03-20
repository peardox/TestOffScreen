TestOffScreen.dproj



This is just a minimal App that displays a model

The 'Grab' button is _supposed_ to create an image from the viewport and save it to test.png but I'm just getting transparencies out :(

Most of this is ignorable - FrameToImage.pas is the class that's _supposed_ to do the work

TFrameExport.Create(AOwner, AWidth, AHeight) 

This basically duplicates the Viewport from the main form

TFrameExport.GrabFromCastleApp(ACastleApp: TCastleApp)

This copies in models from the main VP then performs a Grab

TFrameExport.Grab(AContainer: TCastleContainer)

The bit that's going wrong. It's dead simple - the camera code in it is just replacing a more complex version to get the view right
At the end of this procedure fImageBuffer _should_ hold the current image (want it to be re-usable and repeated which is why it's like this)

Save saves fImageBuffer - it's always blank though :(

Calling it like this for testing....

      frame := TFrameExport.Create(Self, 256,256);
      frame.GrabFromCastleApp(CastleApp);
      frame.Save('../../test.png');
      frame.Clear;
      FreeAndNil(frame);