{***********UNITE*************************************************
Auteur  ...... : Vincent Laroche
Cr�� le ...... : 25/01/2006
Modifi� le ... : 25/01/2006
Description .. : Lek
Suite ........ : Je met en mode 2/3, Je met pour qu'il soit compilable:
Suite ........ : uTob est commun.
Suite ........ : OpenSQL doit �tre avec TQuery.
Mots clefs ... : 
*****************************************************************}
{ Unit� : Source TOF de la FICHE : BALBUDTESEC
--------------------------------------------------------------------------------------
    Version    |   Date   | Qui  |   Commentaires
--------------------------------------------------------------------------------------
                 16/03/05    VL   Cr�ation de l'unit�
 6.50.001.013    09/08/05    JP   Cr�ation de l'anc�tre TOF_CPBALANCEBUDGET

--------------------------------------------------------------------------------------}

unit BALBUDTESEC_TOF;

interface

uses
  StdCtrls, Controls, Classes,
  {$IFDEF EAGLCLIENT}
  MaineAGL, eQRS1,
  {$ELSE}
  db,
  {$IFNDEF DBXPRESS} dbtables, {$ELSE} uDbxDataSet, {$ENDIF}
  FE_Main, QRS1,
  {$ENDIF}
  uTob, SysUtils, ComCtrls,
  {$IFDEF MODENT1}
  CPTypeCons,
  {$ELSE}
  TCalcCum,
  {$ENDIF MODENT1}
  HCtrls, HEnt1, Ent1, CPBALANCEBUDGET_TOF;

procedure BALBUDTESEC;

type

  TOF_BALBUDTESEC = class(TOF_CPBALANCEBUDGET)
    procedure OnArgument(S : string); override;
  public
    procedure PrepCalcBud(SQL : string); override;
    procedure DoInsert(szBudGene, szLibelle, szRub : string; TobFils : Tob);
  end ;

implementation

uses
  {$IFDEF MODENT1}
  ULibExercice,
  {$ENDIF MODENT1}
  UtilEDT,  // ExistBud, WhereLibre, OrderLibre
  CALCOLE,  // GetCumul
  TabLiEdt, // ChoixTableLibreSur, ChoixTableLibre
  TriTabLi; // ChoixTriTableLibre

{---------------------------------------------------------------------------------------}
procedure BALBUDTESEC;
{---------------------------------------------------------------------------------------}
begin
  AGLLanceFiche('CP', 'CPBALBUDTESEC', '', '', '');
end;

{---------------------------------------------------------------------------------------}
procedure TOF_BALBUDTESEC.OnArgument(S : string);
{---------------------------------------------------------------------------------------}
begin
  aTypeBalance := bal_Sect;
  inherited;
end ;

Procedure PasserQry2Tob(var T:Tob;NomTab,Requette:string);
{Lek 250106 Charge la Requette dans Tob}
var Q:TQuery;
begin
  Q:=OpenSql(Requette,true);
  T:=Tob.Create(NomTab,nil,-1);
  T.LoadDetailDB(NomTab,'','',Q,true);
  Ferme(Q);
end;

{---------------------------------------------------------------------------------------}
procedure TOF_BALBUDTESEC.PrepCalcBud(SQL: String);
{---------------------------------------------------------------------------------------}

var
  TNat, TMain, TFinal, TFils, TFind, T : Tob;
  i, j : Integer;
  szData, szOrder : String;
  LTri : TStringList;
begin
//  T := OpenSQL(SQL, True); Lek 250106
  PasserQry2Tob(T,'X',Sql);

  // Pour le tri
  LTri := TStringList.Create;
  szOrder := OrderLibre(GetControlText('FLIBTRIPAR'), True);
  i := Pos(',', szOrder);
  while (i>0) do begin
    System.Delete(szOrder,i,1);
    System.Insert(#10, szOrder, i);
    i := Pos(',', szOrder);
  end;
  LTri.Text := szOrder;

  // Rupture SUR tables libres
  if Rupture in ['T', 'A'] then begin
    // Pour le libell� des tables libres
//    TNat := OpenSQL('SELECT NT_NATURE, NT_LIBELLE FROM NATCPTE WHERE NT_TYPECPTE LIKE "D0%"', True); Lek250106
    PasserQry2Tob(TNat,'Y','SELECT NT_NATURE, NT_LIBELLE FROM NATCPTE WHERE NT_TYPECPTE LIKE "D0%"');
    // Liste des donn�es des tables libres � partir de la requ�te contenu dans SQL
    TMain := TOB.Create('~Main', nil, -1);
    for i := 0 to 9 do
      TOB.Create('TABLE'+IntToStr(i), TMain, -1);

    // T Contient la liste des donn�es des TL et des comptes
    for i := 0 to T.detail.Count-1 do begin
      for j := 0 to 9 do begin
        if T.Detail[i].FieldExists('BS_TABLE'+IntToStr(j)) then begin
          // Recherche si la donn�e est d�j� stock�e
          TFind := nil;
          szData := T.Detail[i].GetString('BS_TABLE'+IntToStr(j));
          if TMain.Detail[j].Detail.Count > 0 then
            TFind := TMain.Detail[j].FindFirst(['CEB_BUDGENE'],[szData], False);

          // Pas trouv� : Cr�e la donn�e
          if (TFind=nil) and (szData<>'') then begin
            TFils :=  Tob.Create('CEDTBALBUD', TMain.Detail[j], -1);
            TFils.PutValue('CEB_UTILISATEUR', V_PGI.User);
            TFils.PutValue('CEB_TRI', LTri.IndexOf('BS_TABLE'+IntToStr(j)));
            TFils.PutValue('CEB_BUDGENE', szData);
            TFind := TNat.FindFirst(['NT_NATURE'], [szData], False);
            if (TFind<>nil) then TFils.PutValue('CEB_LIBELLE',  TFind.GetString('NT_LIBELLE'));
            TFind := TFils;
          end;
          // Cr�e le compte
          TFils := Tob.Create('~COMPTE', TFind, -1);
          TFils.AddChampSup('COMPTE', False);
          TFils.SetString('COMPTE', T.Detail[i].GetString('BS_BUDSECT'));
        end;
      end;
    end;

    // Liste des comptes
    for i := 0 to T.detail.Count-1 do begin
      for j := 0 to 9 do begin
        if T.Detail[i].FieldExists('BS_TABLE'+IntToStr(j)) then begin
          szData := T.Detail[i].GetString('BS_TABLE'+IntToStr(j));
          TFind := TMain.Detail[j].FindFirst(['CEB_BUDGENE'],[szData], False);
          if not(TFind=nil) then
            DoInsert(T.Detail[i].GetString('BS_BUDSECT'), '', T.Detail[i].GetString('BS_RUB'), TFind);
        end;
      end;
    end;

    TNat.Free;
    // Tri les Tob avant insertion
    TFinal := TOB.Create('~CEDTBALBUD', nil, -1);
    for j := 0 to 9 do begin
      while TMain.Detail[j].Detail.Count>0 do begin
        // Supprime les enfants (liste des comptes)
        TMain.Detail[j].Detail[0].ClearDetail;

        // Bascule sur le nouveau parent
        TMain.Detail[j].Detail[0].ChangeParent(TFinal, -1);
      end;
    end;
    TMain.Free;

    TFinal.Detail.Sort('CEB_BUDGENE');
    TFinal.InsertDB(nil, True);
    TFinal.Free;
    end
  else begin
    for i := 0 to T.detail.Count-1 do
      DoInsert(T.Detail[i].GetString('BS_BUDSECT'), T.Detail[i].GetString('BS_LIBELLE'), T.Detail[i].GetString('BS_RUB'), nil);
  end;

  LTri.Free;
  T.Free;
end;

{---------------------------------------------------------------------------------------}
procedure TOF_BALBUDTESEC.DoInsert(szBudGene, szLibelle, szRub: String; TobFils: Tob);
{---------------------------------------------------------------------------------------}
var
  T2, T3 : Tob;
  j : Integer;
  szSQL, szEtab : String;
  FValide : TCheckBox;
  Realise, Ecar : TabTot12;
  TotGen, TotBud : TMontTotal;
  Resol, LeCompte, Lexo : String;
  FinTemp,DateTemp : TDateTime;
  TD : TabloExt;
  Taux : Double;
  Decimale : Integer;
  dbl : Double;
begin
  Fillchar(Realise, SizeOf(Realise), #0);
  Fillchar(Ecar, SizeOf(Ecar), #0);
  Fillchar(TotGen, SizeOf(TotGen), #0);
  Fillchar(TotBud, SizeOf(TotBud), #0);

  // Anciennement dans InitCalcBud
  // Requ�te des mouvements
  szSQL := 'SELECT BE_BUDSECT, BE_EXERCICE, BE_DATECOMPTABLE, BE_NUMEROPIECE, ' +
           'BE_REFINTERNE, BE_ETABLISSEMENT, BE_LIBELLE, BE_VALIDE,' +
           'BE_BUDJAL,BE_NATUREBUD, BE_QUALIFPIECE, BE_DEBIT DEBIT,BE_CREDIT CREDIT ' +
           'FROM BUDECR WHERE BE_BUDSECT="'+szBudGene+'" ' +
           'AND BE_AXE="'+szAxeJal+'" '+
           'AND BE_BUDJAL="'+GetControlText('FJOURNAL')+'" ';

  // FQ 16536 SBO 18/10/2005 Mise en place des options de r�vision dans les balances budg�taires
  if FStWhereNat<>'' then
    szSQL := szSQL + 'AND ' + FStWhereNat + ' ';
  // Fin FQ 16536 SBO 18/10/2005 Mise en place des options de r�vision dans les balances budg�taires

  szSQL := szSQL + 'AND BE_DATECOMPTABLE>="'+usdatetime(StrToDate(FDateCompta1))+'" AND BE_DATECOMPTABLE<="'+usdatetime(StrToDate(FDateCompta2))+'" '+
                   'AND BE_EXERCICE>="'+GetControlText('FEXERCICE')+'" AND BE_EXERCICE<="'+GetControlText('FEXERCICE_')+'" ';
  szEtab := GetControlText('FETAB');
  if szEtab<>'' then szSQL := szSQL + ' AND BE_ETABLISSEMENT="'+szEtab+'" ';
  FValide := TCheckBox(GetControl('FVALIDE', True));
  if FValide.Checked then szSQL := szSQL + ' AND BE_VALIDE="X" ' else
  if FValide.State = cbUnchecked then szSQL := szSQL + ' AND BE_VALIDE="-" ';
  szSQL := szSQL + 'ORDER BY BE_BUDSECT,BE_AXE,BE_EXERCICE,BE_DATECOMPTABLE,BE_BUDJAL,BE_BUDGENE,BE_NUMEROPIECE,BE_QUALIFPIECE';
//  T2 := OpenSQL(szSQL, True);  Lek 250106
  PasserQry2Tob(T2,'Z',szSql);
  
  InitCalcBud(T2, TotBud, GetControlText('FRESOL'), StrToFloat(GetControlText('FTAUX')));
  T2.Free;

  if (TobFils=nil) then begin
    T3 := Tob.Create('CEDTBALBUD', nil, -1);
    T3.InitValeurs(False);
    T3.PutValue('CEB_UTILISATEUR', V_PGI.User);
    T3.PutValue('CEB_BUDGENE', szBudGene);
    T3.PutValue('CEB_LIBELLE', szLibelle);
    end
  else T3 := TobFils;

  for j := 1 to 12 do begin
    // Initial
    dbl := T3.GetValue('CEB_DEBIT'+IntToStr(j));  T3.PutValue('CEB_DEBIT'+IntToStr(j), dbl+TotBud[0][j-1].TotDebit);
    dbl := T3.GetValue('CEB_CREDIT'+IntToStr(j)); T3.PutValue('CEB_CREDIT'+IntToStr(j), dbl+TotBud[0][j-1].TotCredit);

    // R�vis�
    dbl := T3.GetValue('CEB_DEBITREV'+IntToStr(j));  T3.PutValue('CEB_DEBITREV'+IntToStr(j), dbl+TotBud[1][j-1].TotDebit);
    dbl := T3.GetValue('CEB_CREDITREV'+IntToStr(j)); T3.PutValue('CEB_CREDITREV'+IntToStr(j), dbl+TotBud[1][j-1].TotCredit);
  end;
  dbl := T3.GetValue('CEB_TOTDEBIT');     T3.PutValue('CEB_TOTDEBIT', dbl+TotBud[0][12].TotDebit);
  dbl := T3.GetValue('CEB_TOTCREDIT');    T3.PutValue('CEB_TOTCREDIT', dbl+TotBud[0][12].TotCredit);
  dbl := T3.GetValue('CEB_TOTDEBITREV');  T3.PutValue('CEB_TOTDEBITREV', dbl+TotBud[1][12].TotDebit);
  dbl := T3.GetValue('CEB_TOTCREDITREV'); T3.PutValue('CEB_TOTCREDITREV', dbl+TotBud[1][12].TotCredit);

  // Montant du r�alis�
  if GetCheckBoxState('FREALISE')= cbChecked then begin
    LeCompte := 'CBS'+ GetControlText('FJOURNAL') + szRub;

    for j := 1 to 12 do begin
      LExo := QUELEXODTBud(TabDate[j]);
      DateTemp := PlusMois(TabDate[j],1);
      if (Lexo<>QUELEXODTBud(DateTemp)) then LExo := '';
      FinTemp := FinDeMois(TabDate[j]);
      GetCumul('RUBREA',LeCompte,LeCompte,'SAN', GetControlText('FETAB'), 'EUR', LExo, TabDate[j], FinTemp, False, True, Nil, TD, False);
      realise[j-1].TotDebit := TD[3];
      realise[j-1].TotCredit := TD[2];

      dbl := T3.GetValue('CEB_DEBITREA'+IntToStr(j));  T3.PutValue('CEB_DEBITREA'+IntToStr(j), dbl+realise[j-1].TotDebit);
      dbl := T3.GetValue('CEB_CREDITREA'+IntToStr(j)); T3.PutValue('CEB_CREDITREA'+IntToStr(j), dbl+realise[j-1].TotCredit);
    end;

    Resol := GetControlText('FRESOL');
    Taux := StrToFloat(GetControlText('FTAUX'));
    Decimale := 0;
    if Resol='C' then Decimale := V_PGI.OkDecV;

    for j := 0 to 11 do begin
      Reevaluation(Realise[j].TotDebit,Realise[j].TotCredit, Resol, Taux);
      Realise[12].TotDebit := Arrondi(Realise[12].TotDebit + Realise[j].TotDebit, Decimale);
      Realise[12].TotCredit := Arrondi(Realise[12].TotCredit + Realise[j].TotCredit, Decimale);
    end;
    dbl := T3.GetValue('CEB_TOTDEBITREA');  T3.PutValue('CEB_TOTDEBITREA', dbl+Realise[12].TotDebit);
    dbl := T3.GetValue('CEB_TOTCREDITREA'); T3.PutValue('CEB_TOTCREDITREA', dbl+Realise[12].TotCredit);
  end;

  if (TobFils=nil) then begin
    T3.InsertDB(nil);
    T3.Free;
  end;
end;

initialization
  RegisterClasses ( [ TOF_BALBUDTESEC ] );
  
end.
