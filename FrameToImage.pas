unit FrameToImage;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  CastleUIControls, CastleVectors,
  CastleGLUtils, CastleColors,
  CastleViewport,
  CastleTransform,
  CastleDebugTransform,
  CastleScene,
  CastleImages,
  CastleAppUnit;

type

  TFrameExport = class(TComponent)
  private
    fWidth: Integer;
    fHeight: Integer;
    fViewport: TCastleViewport;
    fStage: TCastleScene;
    fCamera: TCastleCamera;
    fCameraLight: TCastleDirectionalLight;
    fAzimuth: Single;
    fInclination: Single;
    fZoomFactor2D: Single;
    fTransparent: Boolean;
    fImageBuffer: TCastleImage;
  public
    procedure CreateViewport;
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; const AWidth: Integer; const AHeight: Integer); reintroduce; overload;
    destructor Destroy; override;
    procedure Clear;
    procedure GrabFromCastleApp(ACastleApp: TCastleApp);
    procedure AddModel(const AModel: TCastleScene);
    procedure Grab(AContainer: TCastleContainer);
    procedure Save(const AFilename: String);
    property Azimuth: Single read fAzimuth write fAzimuth;
    property Inclination: Single read fInclination write fInclination;
    property Zoom: Single read fZoomFactor2D write fZoomFactor2D;
    property Transparent: Boolean read fTransparent write fTransparent;
    property Image: TCastleImage read fImageBuffer write fImageBuffer;
  end;

implementation

uses CastleProjection, CastleGLImages, CastleRectangles, CastleLog;

constructor TFrameExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fTransparent := True;
end;

procedure TFrameExport.AddModel(const AModel: TCastleScene);
var
  ClonedModel: TCastleScene;
begin
  ClonedModel := AModel.Clone(nil);
  fStage.Add(ClonedModel);
  ClonedModel.Free;
end;

procedure TFrameExport.Clear;
begin
  if Assigned(fStage) then
    fStage.Clear;
end;

constructor TFrameExport.Create(AOwner: TComponent; const AWidth: Integer; const AHeight: Integer);
begin
  Create(AOwner);
  fWidth := AWidth;
  fHeight := AHeight;
  CreateViewport;
end;


procedure TFrameExport.CreateViewport;
begin
  fViewport := TCastleViewport.Create(Self);
  fViewport.FullSize := True;
  fViewport.Width := fWidth;
  fViewport.Height := fHeight;
  fViewport.Transparent := True;

  fStage := TCastleScene.Create(Self);
  fViewport.Items.Add(fStage);

  fCamera := TCastleCamera.Create(fViewport);
  fCamera.ProjectionType := ptOrthographic;
  fCamera.Orthographic.Origin := Vector2(0.5, 0.5);

  fCameraLight := CreateDirectionalLight(Self, Vector3(0,0,1));
  fCamera.Add(fCameraLight);

  fViewport.Items.Add(fCamera);

  fViewport.Camera := fCamera;
end;

destructor TFrameExport.Destroy;
begin
  if Assigned(fImageBuffer) then
    fImageBuffer.Free;
  inherited;
end;

procedure TFrameExport.GrabFromCastleApp(ACastleApp: TCastleApp);
begin
  AddModel(ACastleApp.ActiveScene);
  Grab(ACastleApp.Container);
end;

procedure TFrameExport.Grab(AContainer: TCastleContainer);
var
  Image: TDrawableImage;
  RGBA: TRGBAlphaImage;
  ViewportRect: TRectangle;
begin
  try
    RGBA := TRGBAlphaImage.Create(fWidth, fHeight);
    RGBA.ClearAlpha(0);
    Image := TDrawableImage.Create(RGBA, true, true);

    try
      Image.RenderToImageBegin;

      fViewport.Transparent := fTransparent;

      if fCamera.ProjectionType <> ptOrthographic then
        begin
          fCamera.ProjectionType := ptOrthographic;
        end;
      fViewport.Setup2D;
      fCamera.Orthographic.Width := 2;
      fCamera.Orthographic.Origin := Vector2(0.5, 0.5);

      fCamera.Translation := Vector3(1, 1, 1);
      fCamera.Direction := -fCamera.Translation;

      ViewportRect := Rectangle(0, 0, fWidth, fHeight);

      AContainer.RenderControl(fViewport,ViewportRect);

      Image.RenderToImageEnd;

      try
        if fTransparent then
          fImageBuffer := Image.GetContents(TRGBAlphaImage)
        else
          fImageBuffer := Image.GetContents(TRGBImage);
      except
        on E : Exception do
          raise Exception.Create('Inner Exception ' + E.ClassName + ' - ' + E.Message);
      end;
    except
      on E : Exception do
        raise Exception.Create('Outer Exception ' + E.ClassName + ' - ' + E.Message);
    end;
  finally
    FreeAndNil(Image);
  end;

end;

procedure TFrameExport.Save(const AFilename: String);
begin
  if Assigned(fImageBuffer) then
    SaveImage(fImageBuffer, AFilename);
end;

end.
