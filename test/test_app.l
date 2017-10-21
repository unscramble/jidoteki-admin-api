# Load the app files which will be tested

(setq
  *Admin_path   (pack (pwd) "/admin/")
  *Upload_path  (pack *Admin_path "home/sftp/uploads/")
  *Audit_log    (pack *Admin_path "log/jidoteki-audit.log") )
