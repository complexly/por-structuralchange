function correlationsOverTime()

global pp
announceFunction()

%========================================================================%
% Preprocessing
%========================================================================%
S_pearson  = tdfread('save/region_year_corr.tsv','\t');
S_spearman = tdfread('save/region_year_rankcorr.tsv');
T_pearson = struct2table(S_pearson);
T_spearman = struct2table(S_spearman);

correlationMeasure = 'spearman'
switch correlationMeasure
   case 'pearson'
      T_correlations = T_pearson;
   case 'spearman'
      T_correlations = T_spearman;
end

%========================================================================%
% Plot
%========================================================================%
% Additional or customized appearance parameters
fontSize = 16;
braceLineWidth = 1.5;
tickLabels = {
   'Diversity $d$',
   'Fitness',
   '$X_1 d$',
   'Prod. Ability',
   'TCS entropic',
   '$A$',
   '$A^M$',
   '$A^C$',
   'ECI',
   '$b$ (ECI*)',
   '$b^M$ (ECI*$^M$)',
   '$b^C$ (ECI*$^C$)',
   '$X_2 / \sqrt{d}$',
   '$X_2$',
   'GENEPY',
   '$X_1$',
   'Collective knowhow'
   };
year_list = [1966:10:2016];
n_years = length(year_list);

% Setup figure
newFigure(mfilename);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 1127   262])

% Plot
for iyr = 1:n_years
   yr = year_list(iyr);

   % Setup axes
   subaxis(1,n_years,iyr, 'SpacingHoriz', 0.01, 'MarginLeft',0.15)

   % Select data
   corr_matrix = reshape_data(T_correlations, yr);

   % Plot
   hColorbar = seematrix(corr_matrix);

   if iyr ~= n_years
      delete(hColorbar)
   else
      set(hColorbar, 'Position',[0.9157    0.2557    0.01    0.4962], 'FontSize',fontSize)
   end
   
   % Refine
   set(gca, 'Box','on')
   set(gca, 'Layer', 'top')
   set(gca, 'XTick',[1:length(tickLabels)], 'YTick',[1:length(tickLabels)])
   set(gca, 'XTickLabel',[], 'XTickLabelRotation',45)
   set(gca, 'YTickLabel',[])
   set(gca, 'FontSize',fontSize)
   set(gca,'TickLabelInterpreter','latex')
   title(num2str(yr), 'FontWeight','normal');

   % Draw braces
   if iyr == 1
      set(gca, 'Clipping','off')
      braceX0    = 0;
      braceY1    = 1 - 0.4;
      braceY2    = 8 + 0.4;
      braceY3    = 14 + 0.4;
      braceTop1  = [braceX0 braceY1];
      braceTop2  = [braceX0 braceY2];
      braceBot1  = [braceX0 braceY2+0.2];
      braceBot2  = [braceX0 braceY3];
      braceWidth = 10;
      drawbrace(braceTop1, braceTop2, braceWidth, 'Color', 'k', 'LineWidth',braceLineWidth);
      drawbrace(braceBot1, braceBot2, braceWidth, 'Color', 'k', 'LineWidth',braceLineWidth);
   
      % Draw brace labels
      xNudge  = -3;
      yLabel1 = (braceY1 + braceY2)/2;
      text(braceX0+xNudge, yLabel1, 'Diversity-like', 'FontSize',fontSize, 'HorizontalAlignment','right')
      text(-18.7,   10.4953, {'ECI','Composition-like'}, 'FontSize',fontSize, 'HorizontalAlignment','left')
   end

   % Create colorbar
   if iyr == n_years
      set(gca, 'CLim',[0 1])
      nColors    = 100;
      cmapName   = 'parula';
      cmap       = makeColorMap(nColors, cmapName);
      colormap(cmap);
   end

end

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = ['metricCorrelationsOverTime_',correlationMeasure];
   fileName  = fullfile(folder, fileName);

   h.PaperPositionMode = 'auto';
   D = h.PaperPosition;
   h.PaperPosition     = [0 0 D(3) D(4)];
   h.PaperSize         = [D(3) D(4)];

   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end

end




function corr_matrix = reshape_data(T, yr)
T_mod = T(T.year==yr,:); %get yr data
T_mod = unstack(T_mod, 'corrcoef', 'metric2'); %form a matrix


labels = [
   {'diversity'          }
   {'fitness'}
   {'x1d'         }
   {'ability'     }
   {'hc'          }
   {'avgrca_p_1962'    }
   {'avgrca_m_1962'    }
   {'avgrca_c_1962'    }
   {'eci'    } % was eci_year
   {'proj_p_1962'      }
   {'proj_m_1962'      }
   {'proj_c_1962'      }
   {'x2divsqrtd'  }
   {'xc2'}
   {'genepy'}
   {'xc1'}
   {'fe'          }
   ];



% Set metric1 as the row names
T_mod.Properties.RowNames = cellfun(@strip, table2cell(T_mod(:,'metric1')), 'UniformOutput', false);

% Select (and sort) rows and columns to get just matrix of correlations
T_mod = T_mod(labels, labels);

% Convert to matrix
corr_matrix = table2array(T_mod);
end