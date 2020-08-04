      $set sourceformat"free"
      *>----Divisão de identificação do programa
       identification division.
       program-id. "P01SISC20".
       author. "Flavia Tayse Bruno".
       installation. "PC".
       date-written. 03/08/2020.
       date-compiled. 03/08/2020.

      *>----Divisão para configuração do ambiente
       environment division.
       configuration section.
       special-names.
       decimal-point is comma.

      *>----Declaração dos recursos externos
       input-output section.
       file-control.

           select arq-usuarios assign to "arq-usuarios.dat"
           organization is indexed
           access mode is dynamic
           lock mode is manual with lock on multiple records
           record key is fl-user
           file status is ws-fs-arq-usuarios.

       i-o-control.


      *>----Declaração de variáveis
       data division.

      *>----Variáveis de arquivos
       file section.
       fd arq-usuarios.
       01 fl-login-usuario.
           05 fl-user                                  pic x(10).
           05 fl-password                              pic x(08).
           05 fl-tipo-usuario                          pic 9(01) value 2.
               88 fl-adm                               value 0.
               88 fl-usuario                           value 1.
           05 fl-status                                pic 9(01) value 3.
               88 fl-senha-nao-ok                      value 0.
               88 fl-user-nao-ok                       value 1.


      *>----Variáveis de trabalho
       working-storage section.

       77 ws-fs-arq-usuarios                           pic x(02).

       01 ws-fs-login-usuario.
           05 ws-fs-user                               pic x(10).
           05 ws-fs-password                           pic x(08).
           05 ws-fs-tipo-usuario                       pic 9(01) value 2.
               88 ws-fs-adm                            value 0.
               88 ws-fs-usuario                        value 1.
           05 ws-fs-status                             pic 9(01) value 3.
               88 ws-fs-senha-nao-ok                   value 0.
               88 ws-fs-user-nao-ok                    value 1.

       01 ws-msn-erro.
                 05 ws-msn-erro-ofsset                    pic 9(04).
                 05 filler                                pic x(01) value "-".
                 05 ws-msn-erro-cod                       pic x(02).
                 05 filler                                pic x(01) value space.
                 05 ws-msn-erro-text                      pic x(42).

       screen section.
       01  tela-menu.
      *>                                0    1    1    2    2    3    3    4    4    5    5    6    6    7    7    8
      *>                                5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0
      *>                            ----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
           05 blank screen.
           05 line 02 col 01 value "                                Tipo de Usuario                                  ".
           05 line 03 col 01 value "      MENU                                                                       ".
           05 line 04 col 01 value "        [ ]Funcionario                                                           ".
           05 line 05 col 01 value "        [ ]Administrador                                                         ".


      *>                                0    1    1    2    2    3    3    4    4    5    5    6    6    7    7    8
      *>                                5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0
      *>                            ----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
       01 sc-tela.
           05 blank screen.
           05 line 01 col 01 value "                           Autenticacao de senha                               "
           foreground-color 12.
           05 line 03 col 01 value "                   **************************************                      ".
           05 line 04 col 01 value "                   **************************************                      ".
           05 line 05 col 01 value "                   **  USER ID :                       **                      ".
           05 line 06 col 01 value "                   **                                  **                      ".
           05 line 07 col 01 value "                   **  PASSWORD:                       **                      ".
           05 line 08 col 01 value "                   **                                  **                      ".
           05 line 09 col 01 value "                   **                                  **                      ".
           05 line 10 col 01 value "                   **                                  **                      ".
           05 line 11 col 01 value "                   **************************************                      ".
           05 line 12 col 01 value "                   **************************************                      ".


      *>Declaração do corpo do programa
       procedure division.

       0000-controle section.
           perform 1000-inicializa
           perform 2000-processamento
           perform 3000-finaliza
           .
       0000-controle-exit.
           exit.

       1000-inicializa section.
         open i-o arq-usuarios                 *> open i-o abre o arquivo para leitura e escrita
                    if ws-fs-arq-usuarios    <> "00"
                    and ws-fs-arq-usuarios   <> "05" then
                        move 1                                   to ws-msn-erro-ofsset
                        move ws-fs-arq-usuarios                  to ws-msn-erro-cod
                        move "Erro ao abrir arq.usuarios"        to ws-msn-erro-text
                        perform finaliza-anormal

                    end-if
                    .
           1000-inicializa-exit.
               exit.

       2000-processamento section.

           move "N" to ws-fechar-programa
           perform until ws-fechar-programa = "S"
               display "Insira 'A' para administrador e 'F' para funcionario:"
               accept ws-tipo-usuario

               *> ADMINISTRADOR

               if   ws-tipo-usuario = "A" then
                   perform until ws-login-ok
                       call USUARIO (FLAVIA)
                       if   usuario-ok then
                           call PREFERENCIAS (JADE)
                           set ws-login-ok             to true
                           display erase
                           perform until ws-voltar-a = "S"
                               display "Digite 'CP' para cadastrara uma prova, 'CS' para cadastrar um simulado ou 'CR'"
                               display "para consultar resultados:"
                               accept ws-menu-adm
                               if   ws-menu-adm = "CP" then
                                   call PROVA (SORTEIO QUESTOES MADONA)
                               end-if
                               if   ws-menu-adm = "CS" then
                                   call SIMULADO (SORTEIO QUESTOES MADONA)
                               end-if
                               if   ws-menu-adm = "CR" then
                                   call RESULTADOS (JULIA)
                               else
                                   display "Opcao invalida"
                               end-if
                               display "Deseja sair? (S/N)"
                               accept s-voltar-a
                           end-perform
                       else
                           display "Login incorreto"
                           accept ws-aux
                           set ws-login-nao-ok             to true
                       end-if
                   end-perform
               end-if

               *> FUNCIONARIO

               if   ws-tipo-usuario = "F" then
                   perform until ws-login-ok
                       call USUARIO (FLAVIA)
                       if   usuario-ok then
                            call PREFERENCIAS (JADE)
                           set ws-login-ok to true
                           display erase
                           perform until ws-voltar-f = "S"
                               display "Digite 'P' para prova ou 'S' para simulado:"
                               accept ws-menu-funcionario
                               if   ws-menu-funcionario = "P" then
                                   call PROVA (SORTEIO QUESTOES MADONA)
                               end-if
                               if   ws-menu-funcionario = "S" then
                                   call SIMULADO (SORTEIO QUESTOES MADONA)
                               else
                                   display "Opcao invalida"
                               end-if
                           end-perform
                       else
                           display "Login incorreto"
                           accept ws-aux
                           set ws-login-nao-ok             to true
                       end-if
                   end-perform
               else
                   display "Opcao invalida"
                   display "Deseja sair do programa? (S/N)"
                   accept ws-fechar-programa
               end-if
           end-perform



      *> SABER SE É ADMIN OU NAO
      *> FAZER O LOGIN
      *> ADM: SABER O IDIOMA, VERSAO, (Cifra-vigenere)
      *> FUNCIONARIO: IDIOMA, MODO, VERSAO
      *> ADM: CADASTRO PROVA OU SIMULADO (QUESTOES E RESPOSTAS), CONSULTAR RESULTADOS
      *> FUNCIONARIO: SE ESCOLHER PROVA (ARQUIVO VAI GUARDAR AS RESPOSTAS), SIMULADO (ARQUIVO SÓ PRA PEGAR AS QUESTÕES), RESULTADOS: ABRIR ARQ RESULTADOS
      *> ADM: PROVA: ABRIR O ARQ DISCIPLINA - ABRIR ARQ PROVA E ACEITAR AS QUESTÕES E RESPOSTAS, SIMULADO: ABRIR ARQ DISCIPLINA, ABRIR ARQ SIMULADO
      *> FUNCIONARIO: PROVA: ABRE ARQ PROVA E ABRE ARQ RESULTADOS, SALVA (WS) E FECHA, SIMULADO: ABRE ARQ SIMULADO, MOSTRA NA TELA RESULTADO
      *> ADM: VOLTAR PRA TELA DE CADASTRO/CONSULTA
      *> FUNCIONARIO: VOLTAR PRA TELA PROVA/SIMULADO


      *> PERGUNTAR PRO PROF:
      *> SIMULADO
      *> COMO FUNCIONA PROJETOS NO GITHUB


           .
       2000-processamento-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Finalização  Anormal
      *>------------------------------------------------------------------------
       finaliza-anormal section.
           display erase
           display ws-msn-erro.
           stop run
           .
       finaliza-anormal-exit.
           exit.

      *>------------------------------------------------------------------------
      *> Finalização Normal
      *>------------------------------------------------------------------------
       3000-finaliza section.
           stop run
           .
       3000-finaliza-exit.
           exit.




