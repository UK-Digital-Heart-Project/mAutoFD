function [ Rows, Cols ] = pft_GetRowsAndColumns

Options.Resize      = 'off';
Options.WindowStyle = 'modal';
Options.Interpreter = 'tex';

Prompt = { 'Montage rows: ', 'Montage columns: ' };

Starts = { '1', '1' };

Layout = zeros(2, 2, 'int16');
Layout(:, 1) = 1;
Layout(:, 2) = 30;

Answers = pft_InputDlg(Prompt, 'Histology slices', Layout, Starts, Options);

Amended = false;

if (length(Answers) == length(Starts))
  Rows = str2double(Answers{1});
  Cols = str2double(Answers{2});
   
  if ~isnumeric(Rows) 
    Rows = int32(str2double(Starts{1}));
    Amended = true;
  elseif isnan(Rows) || isinf(Rows) || ~isreal(Rows)
    Rows = int32(str2double(Starts{1}));
    Amended = true;
  end
  
  if ~isnumeric(Cols) 
    Cols = int32(str2double(Starts{2}));
    Amended = true;
  elseif isnan(Cols) || isinf(Cols) || ~isreal(Cols)
    Cols = int32(str2double(Starts{2}));
    Amended = true;
  end   
else
  Rows = str2double(Starts{1});
  Cols = str2double(Starts{2});
end

if (Rows < 1)
  Rows = 1;
  Amended = true;
elseif (Rows > 8)
  Rows = 8;
  Amended = true;
end

if (Cols < 1)
  Cols = 1;
  Amended = true;
elseif (Cols > 16)
  Cols = 16;
  Amended = true;
end

if (Amended == true)
  beep;
  
  Caption = '\lambda';
  
  Warning = { 'Input amended:', ...
              ' ', ...
              sprintf('Rows = %1d', Rows), ...
              ' ', ...
              sprintf('Columns = %1d', Cols), ...
              ' ' };
               
  Title   =   'Error correction';
  h = pft_WarnDlg(Warning, Title, 'modal');                
  uiwait(h);
  delete(h);
end
  
end

