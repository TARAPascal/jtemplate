(*
  J-TEmplate plugin.
  Copyright (C) 2012-2014 Silvio Clecio.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit JTemplate;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, StrUtils, Classes, FPJSON;

type

  { TJTemplate }

  TJTemplate = class
  private
    FContent: string;
    FFields: TJSONObject;
    FTagPrefix: ShortString;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromFile(const AFileName: TFileName);
    procedure LoadFromString(const S: string);
    procedure SaveToStream(AStream: TStream);
    procedure SaveToFile(const AFileName: TFileName);
    procedure SaveToString(out S: string);
    procedure Replace; overload;
    procedure Replace(const ARecursive: Boolean); overload;
    property Content: string read FContent write FContent;
    property Fields: TJSONObject read FFields;
    property TagPrefix: ShortString read FTagPrefix write FTagPrefix;
  end;

implementation

constructor TJTemplate.Create;
begin
  FFields := TJSONObject.Create;
  FTagPrefix := '@';
end;

destructor TJTemplate.Destroy;
begin
  FreeAndNil(FFields);
  inherited Destroy;
end;

procedure TJTemplate.LoadFromStream(AStream: TStream);
begin
  if not Assigned(AStream) then
    Exit;
  AStream.Position := 0;
  SetLength(FContent, AStream.Size);
  AStream.Read(Pointer(FContent)^, AStream.Size);
end;

procedure TJTemplate.LoadFromFile(const AFileName: TFileName);
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(VFile);
  finally
    VFile.Free;
  end;
end;

procedure TJTemplate.LoadFromString(const S: string);
var
  VString: TStringStream;
begin
  VString := TStringStream.Create(S);
  try
    LoadFromStream(VString);
  finally
    VString.Free;
  end;
end;

procedure TJTemplate.SaveToStream(AStream: TStream);
begin
  if not Assigned(AStream) then
    Exit;
  AStream.Position := 0;
  AStream.Write(Pointer(FContent)^, Length(FContent));
end;

procedure TJTemplate.SaveToFile(const AFileName: TFileName);
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(VFile);
  finally
    VFile.Free;
  end;
end;

procedure TJTemplate.SaveToString(out S: string);
var
  VString: TStringStream;
begin
  VString := TStringStream.Create('');
  try
    SaveToStream(VString);
    S := VString.DataString;
  finally
    VString.Free;
  end;
end;

procedure TJTemplate.Replace;
var
  PStr: PString;
  I, L, J, P: Integer;
  VName, VValue: string;
begin
  PStr := @FContent;
  for I := 0 to Pred(FFields.Count) do
  begin
    VName := FTagPrefix + FFields.Names[I];
    VValue := FFields.Items[I].AsString;
    for J := 1 to Length(FContent) do
    begin
      P := Pos(VName, FContent);
      if P <> 0 then
      begin
        L := Length(VName);
        System.Delete(PStr^, P, L);
        Insert(VValue, PStr^, P);
        Break;
      end;
    end;
  end;
end;

procedure TJTemplate.Replace(const ARecursive: Boolean);
var
  PStr: PString;
  E, I, L, J, P: Integer;
  VName, VValue: ShortString;
begin
  PStr := @FContent;
  if ARecursive then
  begin
    E := 1;
    for I := 0 to Pred(FFields.Count) do
    begin
      VName := FTagPrefix + FFields.Names[I];
      VValue := FFields.Items[I].AsString;
      for J := 1 to Length(FContent) do
      begin
        P := PosEx(VName, FContent, E);
        if P > E then
          E := P;
        if P <> 0 then
        begin
          L := Length(VName);
          System.Delete(PStr^, P, L);
          Insert(VValue, PStr^, P);
        end;
      end;
    end;
  end
  else
    for I := 0 to Pred(FFields.Count) do
    begin
      VName := FTagPrefix + FFields.Names[I];
      VValue := FFields.Items[I].AsString;
      for J := 1 to Length(FContent) do
      begin
        P := Pos(VName, FContent);
        if P <> 0 then
        begin
          L := Length(VName);
          System.Delete(PStr^, P, L);
          Insert(VValue, PStr^, P);
          Break;
        end;
      end;
    end;
end;

end.
