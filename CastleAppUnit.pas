unit CastleAppUnit;

interface

uses  System.SysUtils, System.Classes, System.Types, CastleViewport,
  CastleUIControls, CastleScene, CastleVectors, CastleTransform,
  SpritelyAxisGrid;

type
  { TCastleApp }
  TCastleApp = class(TCastleView)
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override; // TCastleUserInterface
    procedure Start; override; // TCastleView
    procedure Stop; override; // TCastleView
    procedure Resize; override; // TCastleUserInterface
  private
    Camera: TCastleCamera;
    CameraLight: TCastleDirectionalLight;
    Viewport: TCastleViewport;
    AxisGrid: TAxisGrid;
    function LoadScene(filename: String): TCastleScene;
    procedure LoadViewport;
  public
    ActiveScene: TCastleScene;
    ContainerScene: TCastleScene;
    UniverseScene: TCastleScene;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadAgain;
  end;

function CreateDirectionalLight(const AOwner: TComponent; const LightPos: TVector3): TCastleDirectionalLight;

implementation

uses Math, CastleProjection, CastleFilesUtils;

constructor TCastleApp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TCastleApp.Destroy;
begin
  inherited;
end;

procedure TCastleApp.Update(const SecondsPassed: Single; var HandleInput: Boolean);
begin
  inherited;
end;

procedure TCastleApp.Resize;
begin
//  inherited;
  Viewport.Width := Container.UnscaledWidth;
  Viewport.Height := Container.UnscaledHeight;
  if Camera.ProjectionType = ptOrthographic then
    begin
      if Viewport.Width > Viewport.Height then
        Camera.Orthographic.Height := 1
      else
        Camera.Orthographic.Width := 1;
    end;
end;

procedure TCastleApp.Start;
begin
  inherited;
  LoadViewport;
  UniverseScene := TCastleScene.Create(Self);
  AxisGrid := TAxisGrid.Create(Self, Vector3(0,0,1),2);
  UniverseScene.Add(AxisGrid);

  Viewport.Items.Add(UniverseScene);

  ContainerScene := TCastleScene.Create(Self);
  UniverseScene.Add(ContainerScene);

  ActiveScene := LoadScene('castle-data:/up.glb');
  if Assigned(ActiveScene) then
    begin
      ContainerScene.Add(ActiveScene);
    end;
end;

procedure TCastleApp.LoadAgain;
begin
  ContainerScene.Clear;

  ActiveScene := LoadScene('castle-data:/up.glb');
  if Assigned(ActiveScene) then
    begin
      ActiveScene.Rotation := Vector4(0,1,0,Pi/2);
      ContainerScene.Add(ActiveScene);
    end;
end;

procedure TCastleApp.Stop;
begin
  inherited;
end;

function CreateDirectionalLight(const AOwner: TComponent; const LightPos: TVector3): TCastleDirectionalLight;
var
  Light: TCastleDirectionalLight;
begin
  Light := TCastleDirectionalLight.Create(AOwner);

  Light.Direction := LightPos;
  Light.Color := Vector3(1, 1, 1);
  Light.Intensity := 1;

  Result := Light;
end;

procedure TCastleApp.LoadViewport;
begin
  Viewport := TCastleViewport.Create(Self);
  Viewport.FullSize := False;
  Viewport.Width := Container.UnscaledWidth;
  Viewport.Height := Container.UnscaledHeight;
  Viewport.Transparent := True;

  Camera := TCastleCamera.Create(Viewport);

  Camera.ProjectionType := ptOrthographic;
  Viewport.Setup2D;
  Camera.Orthographic.Width := 2;
  Camera.Orthographic.Origin := Vector2(0.5, 0.5);

  Camera.Translation := Vector3(1, 1, 1);
  Camera.Direction := - Camera.Translation;

  CameraLight := CreateDirectionalLight(Self, Vector3(0,0,1));
  Camera.Add(CameraLight);

  Viewport.Items.Add(Camera);
  Viewport.Camera := Camera;

  InsertFront(Viewport);
end;

function TCastleApp.LoadScene(filename: String): TCastleScene;
begin
  try
    Result := TCastleScene.Create(Self);
    Result.Load(filename);
  except
    on E : Exception do
      begin
        Raise Exception.Create('Error in LoadScene : ' + E.ClassName + ' - ' + E.Message);
       end;
  end;
end;

end.
