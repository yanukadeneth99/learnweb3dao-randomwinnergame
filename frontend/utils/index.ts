import axios from "axios";

export async function subgraphQuery(query: any) {
  try {
    const SUBGRAPH_URL =
      "https://api.thegraph.com/subgraphs/name/yanukadeneth99/learnweb3dao";
    const response = await axios.post(SUBGRAPH_URL, {
      query,
    });
    if (response.data.errors) {
      console.error(response.data.errors);
      throw new Error(`Error making subgraph query ${response.data.errors}`);
    }
    return response.data.data;
  } catch (error: any) {
    console.error(error);
    throw new Error(`Error making subgraph query ${error.message}`);
  }
}
