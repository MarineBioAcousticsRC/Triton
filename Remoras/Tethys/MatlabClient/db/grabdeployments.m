
deployments = ["ALEUT02-BD", "CINMS04-C", "CINMS05-B", "CINMS05-C", ...
    "CINMS05-K", "CINMS08-K3", "CINMS09-C", "CINMS10-B", ...
    "SOCAL31-M", "SOCAL32-M", "SOCAL33-M", "SOCAL34-M", "SOCAL35-M", ...
    "SOCAL37-M", "SOCAL38-M"];

basedir = "U:\Users\mroch\Documents\eclipse\Tethys\server\Tethys\demodb\Source-Docs\Deployments";
for idx = 1:length(deployments)
    fprintf("%s\n", deployments(idx));
    doc = q.getDocument("Deployments", deployments(idx));
        %sprintf("dbxml://Deployments/%s", deployments(idx)));
    fprintf("size:  %d\n", doc.length());
    filename = fullfile(basedir, deployments(idx) + ".xml");
    fileH = fopen(filename, 'w');
    if fileH == -1
        fprintf("Unable to open %s\n", filename);
    else
        fprintf(fileH, string(doc));
        fclose(fileH);
    end
end