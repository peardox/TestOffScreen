unit FMXFormUnit;

interface

// {$define use2dview}

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, Fmx.CastleControl,
  FMX.StdCtrls,
  FrameToImage,
  CastleAppUnit, FMX.Layouts
  ;

type
  { TForm }
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Layout1: TLayout;
    CastleControl1: TCastleControl;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    CastleApp: TCastleApp;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses Math, CastleProjection, CastleFilesUtils;

procedure TForm1.Button1Click(Sender: TObject);
begin
  CastleApp.LoadAgain;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  frame: TFrameExport;
begin
  if Assigned(CastleApp) then
    begin
      frame := TFrameExport.Create(Self, 256,256);
      frame.GrabFromCastleApp(CastleApp);
      frame.Save('../../test.png');
      frame.Clear;
      FreeAndNil(frame);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CastleControl1.Align := TAlignLayout.Client;
  CastleControl1.Parent := Self;
  CastleApp := TCastleApp.Create(CastleControl1);
  CastleControl1.Container.View := CastleApp;
end;

end.
