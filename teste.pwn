//Coding by: RodrigoMSR & ipsLuan

CMD:ativarcash(playerid, params[])
{
    if(sscanf(params, "s[256]", params)) return SendClientMessage(playerid, 0xFF0000FF, "Uso correto: /ativarcash [Código do PagSeguro]");
    CheckPgCode(playerid, params);
    return 1;
}

stock CheckPgCode(playerid, code[])
{
    if(strfind(code, " ", true) != -1) return ShowPlayerDialog(playerid, Dialog_PgSeguro, DIALOG_STYLE_MSGBOX, "Brasil Perfect City - PagSeguro", "Foi encontrado erros durante o processamento do código.\nVerifique o código digitado.", "Fechar", "");
    new str[256];
    format(str, sizeof(str), "www.brasilperfectcity.com.br/pagseguro/pagseguro.php?code=%s", code);
    HTTP(playerid, HTTP_GET, str, "", "HTTP_PgResponse");
    SendClientMessage(playerid, -1, "Estamos procurando o seu pagamento em nosso banco de dados...");
    return 1;
}

stock pg_split(text[], text1[], text2[])
{
    new pos1 = strfind(text, text1, true);
    new pos2 = strfind(text, text2, true);

    new str[256];
    strmid(str, text, pos1+strlen(text1), pos2);
    return str;
}

forward HTTP_PgResponse(playerid, response_code, data[]);
public HTTP_PgResponse(playerid, response_code, data[])
{
    new str[400], statusPg;
    if(!IsPlayerConnected(playerid)) return 1;
    if(response_code == 200)
    {
        new nome[100], code[60], desc[60], Float:valor;
        strcat(code, pg_split(data, "<code>", "</code>"));
        strcat(nome, pg_split(data, "<name>", "</name>"));
        strcat(desc, pg_split(data, "<description>", "</description>"));
        statusPg = strval(pg_split(data, "<status>", "</status>"));
        valor = floatstr(pg_split(data, "<grossAmount>", "</grossAmount>"));
        if(isnull(nome) || valor == 0 || statusPg == 0)
        {
            ShowPlayerDialog(playerid, Dialog_PgSeguro, DIALOG_STYLE_MSGBOX, "Brasil Perfect City - PagSeguro", "Houve um erro durante a consulta do seu código.\n\nFaça novamente a ativação do seu código.\n\nCaso não consiga, entre em contato com um de nossos administradores.", "Fechar", "");
            return 1;
        }
        new statusStr[40];
        switch(statusPg)
        {
            case 1: statusStr = "Aguardando Pagamento";
            case 2: statusStr = "Em Análise";
            case 3: statusStr = "Pagamento Aprovado";
            case 4: statusStr = "Disponível";
            case 5: statusStr = "Em Disputa";
            case 6: statusStr = "Devolvida";
            case 7: statusStr = "Cancelada";
            default: statusStr = "Indefinido";
        }
        format(str, sizeof(str), "Detalhes: \n\n\n\
        {FFFFFF}Código do PagSeguro: {ABDDED}%s\n\
        {FFFFFF}Nome do comprador: {ABDDED}%s\n\
        {FFFFFF}Item comprado: {ABDDED}%s\n\
        {FFFFFF}Status do pagamento: {ABDDED}%s\n\
        {FFFFFF}Valor: {ABDDED}R$ %.2f", code, nome, desc, statusStr, valor);
        if(statusPg != 3 && statusPg != 4)
        {
            format(str, sizeof(str), "%s\n\n{FF0000}Você não pode resgatar ainda o código, porquê ele está: %s.", str, statusStr);
        }
        else
        {
            new file[70];
            format(file, sizeof(file), Pasta_PagSeguro, code);
            if(!fexist(file))
            {
                new dataT[6], datacompleta[100];
                getdate(dataT[0], dataT[1], dataT[2]);
                gettime(dataT[3], dataT[4], dataT[5]);
                format(datacompleta, sizeof(datacompleta), "%02d/%02d/%d - %02d:%02d:%02d", dataT[2], dataT[1], dataT[0], dataT[3], dataT[4], dataT[5]);
                new nomejogador[24];
                GetPlayerName(playerid, nomejogador, 24);
                DOF2_CreateFile(file);
                DOF2_SetString(file, "Codigo", code);
                DOF2_SetString(file, "Comprador", nome);
                DOF2_SetString(file, "Item", desc);
                new valorpago[100];
                format(valorpago, sizeof(valorpago), "R$ %.2f", valor);
                DOF2_SetString(file, "Valor", valorpago);
                DOF2_SetString(file, "Resgatado por", nomejogador);
                DOF2_SetString(file, "Data", datacompleta);
                DOF2_SaveFile();
                //Alterar de acordo com os nomes definidos no pagamento do pagseguro.
                if(strcmp(desc, "VIP-COMUM", true) == 0) {
                    UserInfo[playerid][user_viplevel] = 1;
                    UserInfo[playerid][user_tempovip] += gettime()+(UMDIA*30);
                    format(str, sizeof(str), "Detalhes do pagamento:\n\nCódigo do PagSeguro: %s\nItem comprado: VIP-COMUM (1 mês / 30 dias)\nComprador: %s\nValor: %s\n\nVocê recebeu os seus benefícios corretamente!", code, nome, valorpago);
                }
                if(strcmp(desc, "SÓCIO-COMUM", true) == 0) {
                    UserInfo[playerid][user_viplevel] = 2;
                    UserInfo[playerid][user_tempovip] += gettime()+(UMDIA*30);
                    format(str, sizeof(str), "Detalhes do pagamento:\n\nCódigo do PagSeguro: %s\nItem comprado: SÓCIO-COMUM (1 mês / 30 dias)\nComprador: %s\nValor: %s\n\nVocê recebeu os seus benefícios corretamente!", code, nome, valorpago);
                }
                if(strcmp(desc, "SÓCIO-POWER", true) == 0) {
                    UserInfo[playerid][user_viplevel] = 3;
                    UserInfo[playerid][user_tempovip] += gettime()+(UMDIA*30);
                    format(str, sizeof(str), "Detalhes do pagamento:\n\nCódigo do PagSeguro: %s\nItem comprado: SÓCIO-POWER (1 mês / 30 dias)\nComprador: %s\nValor: %s\n\nVocê recebeu os seus benefícios corretamente!", code, nome, valorpago);
                }
                if(strcmp(desc, "SÓCIO-GOLD", true) == 0) {
                    UserInfo[playerid][user_viplevel] = 4;
                    UserInfo[playerid][user_tempovip] += gettime()+(UMDIA*30);
                    format(str, sizeof(str), "Detalhes do pagamento:\n\nCódigo do PagSeguro: %s\nItem comprado: SÓCIO-GOLD (1 mês / 30 dias)\nComprador: %s\nValor: %s\n\nVocê recebeu os seus benefícios corretamente!", code, nome, valorpago);
                }
                if(strcmp(desc, "SÓCIO-PLATINA", true) == 0) {
                    UserInfo[playerid][user_viplevel] = 5;
                    UserInfo[playerid][user_tempovip] += gettime()+(UMDIA*30);
                    format(str, sizeof(str), "Detalhes do pagamento:\n\nCódigo do PagSeguro: %s\nItem comprado: SÓCIO-PLATINA (1 mês / 30 dias)\nComprador: %s\nValor: %s\n\nVocê recebeu os seus benefícios corretamente!", code, nome, valorpago);
                }
                if(strcmp(desc, "TAXA DE DESBAN", true) == 0) {
                    format(str, sizeof(str), "Detalhes do pagamento:\n\nCódigo do PagSeguro: %s\nItem comprado: TAXA DE DESBAN \nComprador: %s\nValor: %s\n\n\nEntre em contato com algum administrador para solicitar o seu desbanimento.", code, nome, valorpago);
                }
                if(strcmp(desc, "50.000 C$", true) == 0) {
                    GivePlayerCash(playerid, 50000);
                    format(str, sizeof(str), "Detalhes do pagamento:\n\nCódigo do PagSeguro: %s\nItem comprado: 50.000 C$ \nComprador: %s\nValor: %s\n\nVocê recebeu os seus benefícios corretamente!", code, nome, valor);
                }
                if(strcmp(desc, "100.000 C$", true) == 0) {
                    GivePlayerCash(playerid, 100000);
                    format(str, sizeof(str), "Detalhes do pagamento:\n\nCódigo do PagSeguro: %s\nItem comprado: 100.000 C$\nComprador: %s\nValor: %s\n\nVocê recebeu os seus benefícios corretamente!", code, nome, valor);
                }
            }
            else
            {
                ShowPlayerDialog(playerid, Dialog_PgSeguro, DIALOG_STYLE_MSGBOX, "Brasil Perfect City - PagSeguro", "{FFFFFF}ERRO: O código digitado já foi resgatado.\n\nCaso não tenha sido você, entre em contato com um de nossos administradores URGENTE!", "Fechar", "");
                return 1;
            }
        }
        new mensagem[256];
        format(mensagem, sizeof(mensagem), "AdmCmd: O jogador %s resgatou %s pelo /ativarcash.", PlayerGetName(playerid), desc);
        SendAdminMessage(COLOR_LIGHTRED, mensagem);
        ShowPlayerDialog(playerid, Dialog_PgSeguro, DIALOG_STYLE_MSGBOX, "Brasil Perfect City - PagSeguro", str, "Fechar", "");
    }
    else
    {
        format(str, sizeof(str), "{FFFFFF}Ocorreu um erro na consulta de transação.\n\nCódigo do erro: (%d).", response_code);
        ShowPlayerDialog(playerid, Dialog_PgSeguro, DIALOG_STYLE_MSGBOX, "Brasil Perfect City - PagSeguro", str, "Fechar", "");
    }
    return 1;
}
