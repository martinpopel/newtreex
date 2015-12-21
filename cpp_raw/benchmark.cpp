#include <fstream>

#include "common.h"
#include "parsito/tree/tree_format.h"
#include "utils/iostreams.h"

using namespace std;
using namespace ufal::parsito;

int sum;

int main(int argc, char* argv[]) {
  iostreams_init();

  if (argc < 3)
    return cerr << "Usage: " << argv[0] << " input_conllu output_conllu" << endl, 1;

  cout << "init" << endl;

  vector<tree> conllu;
  {
    unique_ptr<tree_input_format> conllu_input_format(tree_input_format::new_conllu_input_format());
    ifstream conllu_is(argv[1]);
    if (!conllu_is)
      return cerr << "Cannot open file " << argv[1] << "!" << endl, 1;

    for (string text; conllu_input_format->read_block(conllu_is, text);) {
      conllu_input_format->set_text(text);
      while (conllu.emplace_back(), conllu_input_format->next_tree(conllu.back())) {}
      if (!conllu_input_format->last_error().empty())
        return cerr << "Cannot load input CoNLL-U: " << conllu_input_format->last_error() << endl, 1;
    }
  }
  cout << "load" << endl;

  {
    unique_ptr<tree_output_format> conllu_output_format(tree_output_format::new_conllu_output_format());
    ofstream conllu_os(argv[2]);
    if (!conllu_os)
      return cerr << "Cannot open file " << argv[2] << "!" << endl, 1;

    string text;
    for (auto&& tree : conllu) {
      conllu_output_format->write_tree(tree, text);
      conllu_os << text;
    }
  }
  cout << "save" << endl;

  {
    for (auto&& tree : conllu)
      for (auto&& node : tree.nodes)
        sum += node.id; // Make sure the loops are not optimized out.
  }
  cout << "iter" << endl;

  {
    for (auto&& tree : conllu)
      for (auto&& node : tree.nodes)
        sum += node.id; // Make sure the loops are not optimized out.
  }
  cout << "iterF" << endl;

  {
    for (auto&& tree : conllu)
      for (auto&& node : tree.nodes) {
        string form_lemma = node.form + node.lemma;
        sum += form_lemma.length(); // Make sure the loops are not optimized out.
      }
  }
  cout << "read" << endl;

  {
    for (auto&& tree : conllu)
      for (auto&& node : tree.nodes)
        node.deprel = "dep";
  }
  cout << "write" << endl;

  return 0;
}
