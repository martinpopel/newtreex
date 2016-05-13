package cz.ufal.udapi.core;

import cz.ufal.udapi.core.impl.DefaultDocument;
import cz.ufal.udapi.exception.UdapiException;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by mvojtek on 3/25/16.
 */
public class Run {

    private boolean dumpScenario;
    private boolean quiet;
    private List<String> fileNames = new ArrayList<>();
    private Map<String,String> globalParams = new HashMap<>();
    private List<String> scenarios = new ArrayList();

    private static final String BLOCK_PACKAGE_PREFIX = "cz.ufal.udapi.block.";
    private static final String UD_BLOCK_PREFIX = "Udapi::Block::";

    public void run(boolean dumpScenario, boolean quiet, String... arguments) {

        this.dumpScenario = dumpScenario;
        this.quiet = quiet;

        boolean separatorFound = false;
        if (arguments.length > 0) {
            for (int i = 0; i < arguments.length; i++) {
                if ("--".equals(arguments[i])) {
                    separatorFound = true;
                    if (i != arguments.length - 1) {
                        fileNames = Arrays.asList(Arrays.copyOfRange(arguments, i + 1, arguments.length));
                    }
                    scenarios = Arrays.asList(Arrays.copyOfRange(arguments, 0, i));
                    break;
                }
            }
            if (!separatorFound) {
                scenarios = Arrays.asList(arguments);
            }
        }

        execute();
    }

    public void execute() {

        if (dumpScenario) {
            //TODO: implement
        }

        String scenarioString = constructScenarioStringWithQuotedWhitespace();

        List<String> blockNames = new ArrayList<>(); //we need to process blocks in correct order
        Map<String, Map<String,String>> blockItems = parseScenarioString(scenarioString, blockNames);

        //load blocks

        Map<String, Class> blocks = loadBlocks(blockItems);
        Map<String, Block> blockInstances = new HashMap<>();

        //instantiate blocks
        for (String blockName : blockNames) {
            Block blockInstance = createBlock(blocks.get(blockName), blockItems.get(blockName));
            blockInstances.put(blockName, blockInstance);
        }

        //load models etc.
        for (String blockName : blockNames) {
            blockInstances.get(blockName).processStart();
        }

        //the main processing
        int numberOfBlocks = blockNames.size();
        int docNumber = 0;
        boolean wasLastDocument = false;

        while (!wasLastDocument) {
            Document newDocument = new DefaultDocument();

            docNumber++;
            int blockNumber = 0;
            for (String blockName : blockNames) {
                blockNumber++;
                if (!quiet) {
                    System.err.println("Applying block " + blockNumber + "/" + numberOfBlocks + " " + blockName);
                }
                Block block = blockInstances.get(blockName);
                block.beforeProcessDocument(newDocument);
                block.processDocument(newDocument);
                block.afterProcessDocument(newDocument);
            }

            //TODO:
            wasLastDocument = true;
        }

        //call processEnd
        for (String blockName : blockNames) {
            blockInstances.get(blockName).processEnd();
        }
    }

    private Map<String, Class> loadBlocks(Map<String, Map<String, String>> blockItems) {
        Map<String, Class> blocks = new HashMap<>();

        //test if blocks are on the classpath
        for (String blockName : blockItems.keySet()) {

            if (null == blockName || "".equals(blockName.trim())) {
                throw new UdapiException("Failed to recognize block name.");
            }

            String className = null;

            if (blockName.startsWith(UD_BLOCK_PREFIX)) {
                //builtin block

                if (blockName.length() > UD_BLOCK_PREFIX.length()) {
                    className = BLOCK_PACKAGE_PREFIX + blockName.substring(UD_BLOCK_PREFIX.length() + 1);
                }

            } else if (blockName.contains(".") || blockName.contains("::")) {
                //user provided block

                if (blockName.contains(".")) {
                    className = blockName;
                } else {
                    String fullBlockName = BLOCK_PACKAGE_PREFIX + blockName;
                    className = fullBlockName.replaceAll("::", ".");
                }

            } else {
                //builtin block without prefix
                className = BLOCK_PACKAGE_PREFIX + blockName;
            }

            try {
                Class blockClass = Class.forName(normalizePackage(className));
                blocks.put(blockName, blockClass);
            } catch (ClassNotFoundException e) {
                throw new UdapiException("Failed to instantiate block " + blockName + ".", e);
            }
        }

        return blocks;
    }

    private String normalizePackage(String fullClassName) {
        int lastDotIndex = fullClassName.lastIndexOf(".");
        if (-1 != lastDotIndex) {
            return fullClassName.substring(0, lastDotIndex).toLowerCase() + fullClassName.substring(lastDotIndex);
        }
        return fullClassName;
    }

    private String constructScenarioStringWithQuotedWhitespace() {
        StringBuilder scenarioString = new StringBuilder();

        Pattern paramPatternWithSpace = Pattern.compile("(\\S+)=(.*\\s.*)$");
        for (int i = 0; i < scenarios.size(); i++) {

            String scenario = scenarios.get(i);
            Matcher m = paramPatternWithSpace.matcher(scenario);

            if (m.matches()) {
                String name = m.group(1);
                String value = m.group(2);

                value = value.replaceAll("'", "\\\\'");
                scenarioString.append(name).append("='").append(value).append("'");
            } else {
                scenarioString.append(scenario).append(" ");
            }

            if (i < scenarios.size() - 1) {
                scenarioString.append(" ");
            }

        }

        return scenarioString.toString();
    }

    private Map<String, Map<String,String>> parseScenarioString(String scenarioString, List<String> blockNames) {
        scenarioString = scenarioString.replaceAll("(?m)#.+$", ""); //delete comments ended by a newline or last line
        scenarioString = scenarioString.replaceAll("\\s+", " "); //collapse whitespaces
        scenarioString = scenarioString.replaceAll("^ ", "");
        scenarioString = scenarioString.replaceAll(" $", "");

        String[] tokens = tokenize(scenarioString);

        //TODO: we are not able to use the same scenario two times
        Map<String, Map<String, String>> result = new HashMap<>();
        String key = "";
        for (int i = 0; i < tokens.length; i++) {
            String token = tokens[i];
            if (token.contains("=")) {
                int equalsIndex = token.indexOf("=");
                String name = token.substring(0, equalsIndex);
                String value;
                if (equalsIndex < token.length() - 1) { // there are some characters after =
                    value = token.substring(equalsIndex+1, token.length());

                    //fix quotes and apostrophes
                    if (value.matches("'.*'")) {
                        value = value.substring(1,value.length()-1);
                        value = value.replaceAll("\\\\'", "'");
                    } else if (value.matches("\".*\"")) {
                        value = value.substring(1,value.length()-1);
                        value = value.replaceAll("\\\\\"", "\"");
                    }
                    result.get(key).put(name, value);
                }

            } else {
                key = token;
                result.put(key, new HashMap<>());
                blockNames.add(key);
            }
        }

        return result;
    }

    private String[] tokenize(String scenarioString) {
        List<String> tokens = new ArrayList<>();

        boolean insideApostrophes = false;
        boolean insideQuotes = false;
        StringBuilder buffer = new StringBuilder();

        char lastChar = '.';
        for (int i = 0; i < scenarioString.length(); i++) {

            char currentChar = scenarioString.charAt(i);

            switch(currentChar) {
                case ' ':
                    if (!insideApostrophes && !insideQuotes) {
                        tokens.add(buffer.toString().trim());
                        buffer.setLength(0);
                    } else {
                        buffer.append(" ");
                    }
                    lastChar = ' ';
                    break;
                case '\'':
                    if (insideApostrophes && lastChar != '\\') {
                        insideApostrophes = false;
                    } else if (!insideApostrophes && !insideQuotes && lastChar != '\\') {
                        insideApostrophes = true;
                    }
                    lastChar = '\'';
                    buffer.append(lastChar);
                    break;
                case '"':
                    if (insideQuotes && lastChar != '\\') {
                        insideQuotes = false;
                    } else if (!insideApostrophes && !insideQuotes && lastChar != '\\') {
                        insideQuotes = true;
                    }
                    lastChar = '"';
                    buffer.append(lastChar);
                    break;
                default:
                    lastChar = currentChar;
                    buffer.append(lastChar);
            }
        }

        if (buffer.length() > 0) {
            String bufferString = buffer.toString();
            if (!"".equals(bufferString.trim())) {
                tokens.add(bufferString.trim());
            }
        }

        return tokens.toArray(new String[0]);
    }

    private Block createBlock(Class blockClass, Map<String, String> parameters) {

        //initialize with global parameters
        Map<String, String> blockParameters = new HashMap<>();
        blockParameters.putAll(globalParams);

        //override global parameters with block parameters
        blockParameters.putAll(parameters);

        try {
            return (Block)blockClass.getConstructor(Map.class).newInstance(blockParameters);
        } catch (Exception e) {
            //fallback to default constructor
            try {
                return (Block)blockClass.getConstructor().newInstance();
            } catch (Exception other) {
                throw new UdapiException("Failed to instantiate block.", other);
            }
        }

    }


}
