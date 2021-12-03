report zrsus050.

tables agr_1251.

types gt_t_outtab type standard table of sim_rsusr050_alv.

types:
  begin of t_table,
    role type agr_1251-agr_name.
    include type sim_rsusr050_alv.
types: end of t_table,
tt_table type standard table of t_table.

types:
  begin of ts_one_role,
    agr_name type agr_name,
    sys_flag type rfcdest,
  end of ts_one_role,
  tt_one_role type table of ts_one_role.

types: tt_outtab_crole type table of sim_rsusr050_alv_role.

types:
  begin of t_table_cr,
    role type agr_1251-agr_name.
    include type sim_rsusr050_alv_role.
types: end of t_table_cr,
tt_table_cr type standard table of t_table_cr.

types:
  begin of ts_compare_role,
    role1 type agr_name,
    role2 type agr_name,
  end of ts_compare_role,
  tt_compare_role type table of ts_compare_role.

selection-screen begin of block b00.

select-options s_roles for agr_1251-agr_name.
parameters p_rfc type rfcdes-rfcdest.

selection-screen end of block b00.

initialization.

  %_s_roles_%_app_%-text = 'Roles'.
  %_p_rfc_%_app_%-text = 'RFC Destination'.

start-of-selection.

  constants icon1 type lvc_fname value 'ICONID1'.
  constants icon2 type lvc_fname value 'ICONID2'.
  constants icon3 type lvc_fname value 'ICONID3'.

  data rc.
  data table type ref to cl_salv_table.
  data comparison type tt_table.
  data comparison_cr type tt_table_cr.


  field-symbols <rfc> type rfcdes-rfcdest.
  field-symbols <operand1> type char45.
  field-symbols <operand2> type char45.
  field-symbols <rol1> type agr_define-agr_name.
  field-symbols <rol2> type agr_define-agr_name.
  field-symbols <rolea> type tt_one_role.
  field-symbols <roleb> type tt_one_role.
  field-symbols <aut1> type user1_auth.
  field-symbols <aut2> type user1_auth.
  field-symbols <role_equal> type tt_compare_role.
  field-symbols <role_diff> type tt_compare_role.
  field-symbols <gt_outtab> type gt_t_outtab.
  field-symbols <gt_outtab_cr> type tt_outtab_crole.
  field-symbols <listdata> type user1_user_list.

  perform dummy in program rsusr050 if found.

  assign ('(RSUSR050)SYST_1') to <rfc>.
  assign ('(RSUSR050)OPERAND1') to <operand1>.
  assign ('(RSUSR050)OPERAND2') to <operand2>.
  assign ('(RSUSR050)ROL_1') to <rol1>.
  assign ('(RSUSR050)ROL_2') to <rol2>.
  assign ('(RSUSR050)IT_ROLE_A[]') to <rolea>.
  assign ('(RSUSR050)IT_ROLE_B[]') to <roleb>.
  assign ('(RSUSR050)AUT1') to <aut1>.
  assign ('(RSUSR050)AUT2') to <aut2>.
  assign ('(RSUSR050)IT_ROLE_EQUAL[]') to <role_equal>.
  assign ('(RSUSR050)IT_ROLE_DIFF[]') to <role_diff>.
  assign ('(RSUSR050)T_LISTDAT') to <listdata>.
  assign ('(RSUSR050)GT_OUTTAB') to <gt_outtab>.
  assign ('(RSUSR050)GT_OUTTAB_CR') to <gt_outtab_cr>.

  <rfc> = p_rfc.
  loop at s_roles assigning field-symbol(<role>).
    <rol1> = <rol2> = <operand1> = <operand2> = <role>-low.
    perform role_compare in program rsusr050 changing rc.

    loop at <gt_outtab> assigning field-symbol(<outtab>).
      append initial line to comparison assigning field-symbol(<comparison>).
      <comparison> = corresponding #( <outtab> ).
      <comparison>-role = <role>-low.
    endloop.

    loop at <gt_outtab_cr> assigning field-symbol(<outtab_cr>).
      append initial line to comparison_cr assigning field-symbol(<comparison_cr>).
      <comparison_cr> = corresponding #( <outtab_cr> ).
      <comparison_cr>-role = <role>-low.
    endloop.

    clear <gt_outtab>.
    clear <gt_outtab_cr>.
    clear <rolea>.
    clear <roleb>.
    clear <aut1>.
    clear <aut2>.
    clear <role_equal>.
    clear <role_diff>.
    clear <listdata>.

  endloop.

  try.
      if <comparison_cr> is assigned.
        cl_salv_table=>factory(
          importing
            r_salv_table = table
          changing
            t_table      =  comparison_cr ).
      else.
        cl_salv_table=>factory(
          importing
            r_salv_table = table
          changing
            t_table      =  comparison ).
      endif.
    catch cx_salv_msg.                                  "#EC NO_HANDLER
  endtry.

  table->get_functions( )->set_all( ).
  table->get_columns( )->set_optimize( ).

  table->get_columns( )->get_column( icon1 )->set_medium_text( 'Remote' ).
  table->get_columns( )->get_column( icon2 )->set_medium_text( 'Local' ).
  table->get_columns( )->get_column( icon3 )->set_medium_text( 'Comparison' ).

  table->get_sorts( )->add_sort( 'ROLE' ).

  table->display( ).
